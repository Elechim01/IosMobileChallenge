//
//  UserList.swift
//  IosMobileChallenge
//
//  Created by Michele Manniello on 11/12/21.
// Chiedere cosa intende per nome del pacchetto, se è la somma dell nome utente + il progetto oppure solo il progetto che deve essere minore di 20 caratteri ?


import Foundation
import UIKit

public class UserList:ObservableObject{
    
    public init() {
        
    }
    
    @Published public var value : String = ""
    @Published public var error : String = ""
    
    public func GetUser(owner:String,name:String){
//        controllare se il device è sicuro...
//        controllo se il deice è un simulatore
//        controllo se il device jailBroken
        #if targetEnvironment(simulator)
        error = "Device is Simulator"
        #else
        if UIDevice.current.isJailBroken == false{
            if #available(iOS 13.0, *){
                
                if !isConnectedToVpn{
                    let controllo = owner + name
                    
                    if controllo.count >= 20{
                        error = "Name + owne are to long"
                    }
                    
            var url = URL(string: "https://api.github.com/repos/\(owner)/\(name)/stargazers")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, _, err in
                if err != nil{
                    
                    print(err!.localizedDescription)
                    return
                }
                guard let response = data else { return }
                do {
                    
                    let valoriJS = try JSONSerialization.jsonObject(with: response, options: .fragmentsAllowed) as! Array<Dictionary<String, AnyObject>>
                    
                    for elment in valoriJS{
                        if let login = elment["login"]{
                            DispatchQueue.main.async {
                                self.value += "\(login)\n"
                                print(self.value)
                            }
                           
                            
                        }
                    }
                    
                } catch  {
                    print(err!.localizedDescription)
                }
            }
            task.resume()
                    
                }else{
                   error = "Ios Devce is connected to VPN"
                }
            }else{
                error = "IOS version is old,the application is compatible with IOS 13.0 or later"
            }
            
        }else{
            error = "Device is JailBroken"
        }
        
        #endif
        
    }
    
    private var isConnectedToVpn: Bool {
        if let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? Dictionary<String, Any>,
            let scopes = settings["__SCOPED__"] as? [String:Any] {
            for (key, _) in scopes {
             if key.contains("tap") || key.contains("tun") || key.contains("ppp") || key.contains("ipsec") {
                    return true
                }
            }
        }
        return false
    }
    
}

extension UIDevice{
    var isSimulator: Bool{
        return TARGET_OS_SIMULATOR != 0
    }
    
    public var isJailBroken: Bool{
        get{
            if UIDevice.current.isSimulator{return false}
            if JailBrokenHelper.hasCydiaInstalled(){return true}
            if JailBrokenHelper.isContainSuspiciusApps(){return true}
            if JailBrokenHelper.isSuspociousSystempathExists(){return true}
            return JailBrokenHelper.casEditSystemFiles()
        }
    }
}

private struct JailBrokenHelper{
    
//    controllo se cydia is installed (using URI Scheme)
    static func hasCydiaInstalled()->Bool{
        return UIApplication.shared.canOpenURL(URL(string: "cydia://")!)
    }
    
//    controllo se le app di cydia sono state installate...
    static func isContainSuspiciusApps()->Bool{
        for path in suspiciusAppPathToCheck{
            if FileManager.default.fileExists(atPath: path){
                return true
            }
        }
        return false
    }
    
//    cheking if system contains suspicious files
    
    static func isSuspociousSystempathExists()->Bool{
        for path in suspiciousSystemPathsToCheck {
            if FileManager.default.fileExists(atPath: path){
                return true
            }
        }
        return false
    }
    
//    cheking id app can edit system files..
    
    static func casEditSystemFiles()->Bool{
        let jailBreakText = "Developer Inside"
        do {
            try jailBreakText.write(toFile: jailBreakText, atomically: true, encoding: .utf8)
            return true
        } catch  {
            return false
        }
    }
    
//    suspicius apps to check
    static var suspiciusAppPathToCheck: [String]{
        return["/Applications/Cydia.app",
               "/Applications/blackra1n.app",
               "/Applications/FakeCarrier.app",
               "/Applications/Icy.app",
               "/Applications/IntelliScreen.app",
               "/Applications/MxTube.app",
               "/Applications/RockApp.app",
               "/Applications/SBSettings.app",
               "/Applications/WinterBoard.app"
        ]
    }
    
//    suspicius system paths to check
    
    static var suspiciousSystemPathsToCheck:[String]{
        return["/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
               "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
               "/private/var/lib/apt",
               "/private/var/lib/apt/",
               "/private/var/lib/cydia",
               "/private/var/mobile/Library/SBSettings/Themes",
               "/private/var/stash",
               "/private/var/tmp/cydia.log",
               "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
               "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
               "/usr/bin/sshd",
               "/usr/libexec/sftp-server",
               "/usr/sbin/sshd",
               "/etc/apt",
               "/bin/bash",
               "/Library/MobileSubstrate/MobileSubstrate.dylib"
        ]
    }
    
    
    
}
