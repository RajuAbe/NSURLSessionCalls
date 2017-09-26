//
//  ServiceCalls.swift
//  Sarvam
//
//  Created by Raju on 03/01/17.
//  Copyright © 2017 Appiness. All rights reserved.
//

import Foundation

class ServiceCalls: NSObject {
    
    // Global Veriables

    var defaultSession: URLSession?
    var dataTask: URLSessionDataTask?
    
    var responseInDictionary: NSDictionary?
    var statusCode: Int?
    
    // MARK: - Post Method
    /* Post request with request parameters
     - Parameter fullURL : full url of requestfull
     - Parameter requestDict: Request parameters in dictionary
     
     - Completion data:Dictionary - response in dictionary
     - CompCompletion statusCode: Int - Status Code
     */
    func postDataRequest(urlString: String, requestDic: Dictionary<String,AnyObject>, completion:@escaping (_ data:NSDictionary,_ statusCode:Int) -> ()) {
        
        let url = URL(string: urlString)
        defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
   
        request.httpBody = try! JSONSerialization.data(withJSONObject: requestDic, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Authentication Token // JWT ... etc.,
        /*
        if let token = UserDefaults.standard.object(forKey: "token"){
            let tokenStr = "JWT \(token as! String)"
            request.setValue(tokenStr, forHTTPHeaderField: "Authorization")
        }
        */
        self.doSessionTask(request: request, session: self.defaultSession!) {
            (data,statusCode) in
            
            self.responseInDictionary = data
            self.statusCode = statusCode
            completion(data, statusCode)
    }
    
    // MARK: - Put Method
    /* Post request with request parameters
     - Parameter fullURL : full url of requestfull
     - Parameter requestDict: Request parameters in dictionary
     
     - Completion data:Dictionary - response in dictionary
     - CompCompletion statusCode: Int - Status Code
     */
    func putDataRequest(urlString: String, requestDic: Dictionary<String,AnyObject>, completion:@escaping (_ data:NSDictionary,_ statusCode:Int) -> ()) {
    
        let url = URL(string: urlString)
       
        defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "PUT"
        request.httpBody = try! JSONSerialization.data(withJSONObject: requestDic, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Authentication Token // JWT ... etc.,
        /*
        if let token = UserDefaults.standard.object(forKey: "token") as? String{
            let tokenStr = "JWT \(token)"
            request.setValue(tokenStr, forHTTPHeaderField: "Authorization")
        }
        */
        self.doSessionTask(request: request, session: self.defaultSession!) {
            (data,statusCode) in
            self.responseInDictionary = data
            self.statusCode = statusCode
            completion(data, statusCode)
        }
    }
    
    // MARK: - Get Method
    /* Post request with request parameters
     - Parameter fullURL : full url of requestfull

     - Completion data:Dictionary - response in dictionary
     - CompCompletion statusCode: Int - Status Code
     */
    func getDataRequest(urlString: String, completion:@escaping (_ data:NSDictionary,_ statusCode:Int) -> ()) {
    
        let url = URL(string: urlString)
        defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Authentication Token // JWT ... etc.,
        /*
        if let token = UserDefaults.standard.object(forKey: "token") as? String {
            let tokenStr = "JWT \(token)"
            request.setValue(tokenStr, forHTTPHeaderField: "Authorization")
        }
         */
        
        self.doSessionTask(request: request, session: self.defaultSession!) {
            (data,statusCode) in
            
            self.responseInDictionary = data
            self.statusCode = statusCode
            completion(data, statusCode)
        }
    }

    // MARK: - For All Methods
    /* Post request with request parameters
     - Parameter fullURL : full url of requestfull
     - Parameter httpMethod : HTTP Method
     - Parameter requestDict: Request parameters in dictionary / optional
         
     - Completion data:Dictionary - response in dictionary
     - CompCompletion statusCode: Int - Status Code
     */
    func sendOptionalData(urlString: String, httpMethod: String, requestDic:Dictionary<String,AnyObject>? = nil, completion:@escaping (_ data: NSDictionary, _ statusCode:Int) -> ()){
    
        let url = URL(string: urlString)
        
        defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        
        var request = URLRequest(url: url!)
        request.httpMethod = httpMethod
        if requestDic != nil {
            request.httpBody = try! JSONSerialization.data(withJSONObject: requestDic!, options: [])
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Authentication Token // JWT ... etc.,
        /*
        if let token = UserDefaults.standard.object(forKey: "token"){
            let tokenStr = "JWT \(token as! String)"
            request.setValue(tokenStr, forHTTPHeaderField: "Authorization")
            
        }
         */
        
        self.doSessionTask(request: request, session: self.defaultSession!) {
            (data,statusCode) in
            
            self.responseInDictionary = data
            self.statusCode = statusCode
            completion(data, statusCode)
        }
        
    }

    // MARK: - Session Task Doing
    /* doing NSURL Session Task
         - Parameter request: URLRequst with body method and headers
         - Parameter session : URLSession
         - Completion data:Dictionary - response in dictionary
         - CompCompletion statusCode: Int - Status Code
     
     */
    func doSessionTask(request: URLRequest, session: URLSession, completion: @escaping (_ data: NSDictionary, _ statusCode: Int) -> Void) {
        
        // checking network connection
        if Reachability.isConnectedToNetwork() {
            // default session with data task
            dataTask = defaultSession?.dataTask(with: request){ data,response,error in
                // handling error
                if let error = error {
                    self.statusCode = 500
                    self.responseInDictionary = ["error":error.localizedDescription]
                    completion(self.responseInDictionary!, self.statusCode!)
                }
                else if let httpResponse = response as? HTTPURLResponse {
                    self.statusCode = httpResponse.statusCode
                    guard let responseData = data else {
                        // no response parameters
                        self.responseInDictionary = ["error":"did not recived any data"]
                        completion(self.responseInDictionary!, self.statusCode!)
                        return
                    }

                    // parse the result as JSON
                    do {
                        // parse Response as Dictionary
                        guard let res = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                            // Parse Response as NSArray
                            guard let resp = try JSONSerialization.jsonObject(with: responseData, options: []) as? NSArray else {
                                self.responseInDictionary = ["error":"Can't convert to JSON"]
                                completion(self.responseInDictionary!, self.statusCode!)
                                return
                            }
                            let dict = ["data":resp]
                            self.responseInDictionary = dict as NSDictionary!
                            completion(self.responseInDictionary!, self.statusCode!)
                            return
                        }
                        self.responseInDictionary = res as NSDictionary!
                        completion(self.responseInDictionary!, self.statusCode!)
                        
                    } catch let error as NSError {
                        self.responseInDictionary = ["error":error.localizedDescription]
                        completion(self.responseInDictionary!, self.statusCode!)
                    }
                } else {
                    self.responseInDictionary = ["error":"Something wrong"]
                    self.statusCode = 500
                    completion(self.responseInDictionary!, self.statusCode!)
                }
            }
            dataTask?.resume()
        } else {
            statusCode = 500
            responseInDictionary = ["error":"No Internet Connection"]
            completion(self.responseInDictionary!, self.statusCode!)
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
        
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }

}
