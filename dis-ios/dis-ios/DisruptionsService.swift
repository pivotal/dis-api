import Foundation
import Alamofire
import SwiftyJSON

public enum DisruptionsDataKeys : String {
    case Root = "disruptions"
    case Line = "line"
}

public class DisruptionsService: DisruptionsServiceProtocol {

    var alamofireManager: Manager
    
    init(){
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 10
        config.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        
        self.alamofireManager = Alamofire.Manager(configuration: config)
    }
    
    public func getDisruptions(onSuccess: (disruptions: [String]) -> Void, onError: (error: String) -> Void){
        var url = ""
        
        #if TEST
            url = "http://localhost:8080/disruptions.json"
        #else
            url = "https://pivotal-london-dis-digest.s3.amazonaws.com/disruptions.json"
        #endif
        
        self.alamofireManager.request(.GET, url).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)[DisruptionsDataKeys.Root.rawValue]
                    
                    var disruptions = [String]()
                    for(_, disruptionData):(String, JSON) in json {
                        disruptions.append(disruptionData[DisruptionsDataKeys.Line.rawValue].string!)
                    }
                    
                    onSuccess(disruptions: disruptions)
                }
            case .Failure(_):
                onError(error: "Couldn't retrieve data from server :(")
            }
        }
        
        
    }
}
