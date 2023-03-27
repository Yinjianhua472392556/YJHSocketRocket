//
//  YJHSocketRocket.swift
//  YJHSocketRocket
//
//  Created by 尹建华 on 2023/3/27.
//

import Foundation
import RxSwift
import RxCocoa
import SocketRocket
import SwifterSwift

public protocol TZYKSocketRocketDelegate: NSObjectProtocol {
    func sr_didOpen()
    func sr_didReceiveMessage(message: Any)
    func sr_didReceiveMessage(string: String)
    func sr_didReceiveMessage(data: Data)
    func sr_didFail(error: Error)
    func sr_didClose(code: Int, reason: String?, wasClean: Bool)
}

public extension TZYKSocketRocketDelegate {
    func sr_didOpen() {}
    func sr_didReceiveMessage(message: Any) {}
    func sr_didReceiveMessage(string: String) {}
    func sr_didReceiveMessage(data: Data) {}
    func sr_didFail(error: Error) {}
    func sr_didClose(code: Int, reason: String?, wasClean: Bool) {}
}

public class YJHSocketRocket: NSObject {
    
//    public var baseUrl = TZYKRequestConfig.shared.gatewayDomain_Sign().replacingOccurrences(of: "https", with: "wss")
    public var baseUrl: String = ""
    weak var delegate: TZYKSocketRocketDelegate? = nil
    /// 心跳包数据
    public var heartbeatData: Data? = ["msgType": 1].jsonData()
    /// 心跳包间隔
    public var heartbeatInterval: Int = 60
    /// 最大重连次数
    public var maximumReconnectNumber: Int = 5
    /// 链接状态 SRReadyState
    public var readyState: Int {
        return socketManager.readyState.rawValue
    }
    
    let defaultUrl = URL(string: "www.baidu.com")!
    var connectedUrl: String = ""
    /// SRWebSocket
    var socketManager: SRWebSocket
    /// 心跳
    var heartbeatBag = DisposeBag()
    /// 标记是否用户主动关闭
    var isUserClose = false
    /// 当前重连次数
    var currentReconnectNumber = 0
    
    public init(url: String) {
        connectedUrl = baseUrl + "/" + url
        socketManager = SRWebSocket(url: URL(string: connectedUrl) ?? defaultUrl)
        super.init()
        socketManager.delegate = self
    }
}

extension YJHSocketRocket: SRWebSocketDelegate {
    
    public func webSocketDidOpen(_ webSocket: SRWebSocket) {
        debugPrint("webSocketDidOpen")
        delegate?.sr_didOpen()
        // 重置重连统计
        currentReconnectNumber = 0
    }
    
    public func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        debugPrint("didFailWithError:\(error)")
        if currentReconnectNumber > maximumReconnectNumber {
            delegate?.sr_didFail(error: error)
        }
        reconnect()
    }
    
    public func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
        debugPrint("didCloseWithCode:\(code), reason:\(reason ?? ""), wasClean:\(wasClean)")
        guard isUserClose == false else {
            delegate?.sr_didClose(code: code, reason: reason, wasClean: wasClean)
            return
        }
        
        // 不是主动关闭，尝试重连
        if currentReconnectNumber > maximumReconnectNumber {
            delegate?.sr_didClose(code: code, reason: reason, wasClean: wasClean)
            return
        }
        reconnect()
    }
    
    public func webSocket(_ webSocket: SRWebSocket, didReceivePingWith data: Data?) {
        debugPrint("didReceivePing:\(data ?? Data())")
    }
    
    public func webSocket(_ webSocket: SRWebSocket, didReceivePong pongData: Data?) {
        debugPrint("didReceivePong:\(pongData ?? Data())")
    }
    
    // MARK: - data
    public func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
        delegate?.sr_didReceiveMessage(message: message)
    }
    
    public func webSocket(_ webSocket: SRWebSocket, didReceiveMessageWith string: String) {
        debugPrint("didReceiveMessageString:\(string)")
        delegate?.sr_didReceiveMessage(string: string)
    }
    
    public func webSocket(_ webSocket: SRWebSocket, didReceiveMessageWith data: Data) {
        debugPrint("didReceiveMessageData:\(data)")
        delegate?.sr_didReceiveMessage(data: data)
    }
    
}

extension YJHSocketRocket {
    func reconnect() {
        // 达到最大重连次数，拦截
        guard currentReconnectNumber <= maximumReconnectNumber else { return }
        guard let url = URL(string: connectedUrl) else { return  }
        
        isUserClose = false
        currentReconnectNumber += 1
        socketManager.delegate = nil
        socketManager = SRWebSocket(url: url)
        socketManager.delegate = self
        open()
    }
    
    func startHeartBeat() {
        stopHeartbeat()
        Observable<Int>
            .interval(RxTimeInterval.seconds(heartbeatInterval),
                      scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe { [weak self] _ in
                self?.sendHeartbeat()
            }.disposed(by: heartbeatBag)
    }
    
    func stopHeartbeat() {
        heartbeatBag = DisposeBag()
    }
}

public extension YJHSocketRocket {
    
    /// 开
    func open() {
        guard socketManager.readyState == .CONNECTING else { return }
        socketManager.open()
    }
    
    /// 关
    /// - Parameters:
    ///   - code: 参考SRStatusCode
    ///   - reason: 随便写
    func close(code: Int? = nil, reason: String? = nil) {
        isUserClose = true
        socketManager.close(withCode: code ?? SRStatusCode.codeNormal.rawValue, reason: reason)
    }
    
    /// 重连
    func reconnect(url: String) {
        
        isUserClose = true
        socketManager.delegate = nil
        socketManager.close()
        
        connectedUrl = baseUrl + "/" + url
        guard let url = URL(string: connectedUrl) else { return }
        isUserClose = false
        currentReconnectNumber = 0
        socketManager = SRWebSocket(url: url)
        socketManager.delegate = self
        open()
    }
    
    /// 发送消息
    func sendMessage(data: Data?) {
        do {
            try socketManager.send(data: data)
        } catch  {
            debugPrint("消息发送失败")
        }
    }
    
    /// 发送消息
    func sendMessage(string: String) {
        do {
            try socketManager.send(string: string)
        } catch {
            debugPrint("消息发送失败")
        }
    }
    
    /// 发送心跳
    func sendHeartbeat(data: Data? = nil) {
        sendMessage(data: data ?? heartbeatData)
    }
    
    /// 自动心跳
    func startAutoHeartbeat() {
        startHeartBeat()
    }
    
}
