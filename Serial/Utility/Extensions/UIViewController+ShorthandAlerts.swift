//
//  UIViewController+ShorthandAlerts.swift
//
//  Created by Ayden Panhuyzen on 2017-07-31.
//  Copyright © 2017-2018 Ayden Panhuyzen. All rights reserved.
//  https://gist.github.com/aydenp
//

import UIKit

fileprivate let unknownErrorMessage = NSLocalizedString("An unknown error has occurred", comment: "A message showing that an error has occurred, but the specific error causing it is unknown.")

extension UIViewController {
    
    /// Show an alert on the view controller.
    func showAlert(title: String? = nil, message: String? = nil, preferredStyle: UIAlertController.Style = .alert, actions: [UIAlertAction] = [.ok], completion: (() -> Void)? = nil) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                self.showAlert(title: title, message: message, preferredStyle: preferredStyle, actions: actions, completion: completion)
            }
            return
        }
        let alert = UIAlertController.createAlert(title: title, message: message, preferredStyle: preferredStyle, actions: actions, completion: completion)
        present(alert, animated: true, completion: completion)
    }
    
    /// Show an alert on the view controller.
    func showAlert(title: String? = nil, message: String? = nil, preferredStyle: UIAlertController.Style = .alert, action: UIAlertAction, completion: (() -> Void)? = nil) {
        showAlert(title: title, message: message, preferredStyle: preferredStyle, actions: [action], completion: completion)
    }
    
    /// Show an alert on the view controller for the specified error.
    func showErrorAlert(title: String? = nil, error: Error?, unknownMessage: String = unknownErrorMessage, actions: [UIAlertAction] = [.ok], completion: (() -> Void)? = nil) {
        showAlert(title: title, message: error?.localizedDescription ?? unknownMessage, actions: actions, completion: completion)
    }
    
    /// Show an alert on the view controller for the specified error.
    func showErrorAlert(title: String? = nil, error: Error?, unknownMessage: String = unknownErrorMessage, action: UIAlertAction, completion: (() -> Void)? = nil) {
        showErrorAlert(title: title, error: error, actions: [action], completion: completion)
    }
    
}

extension UIAlertController {
    
    static func createAlert(title: String? = nil, message: String? = nil, preferredStyle: UIAlertController.Style = .alert, actions: [UIAlertAction] = [.ok], completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = self.init(title: title, message: message, preferredStyle: preferredStyle)
        actions.forEach({ alert.addAction($0) })
        return alert
    }
    
}

// Extend UIAlertAction to have quick and Swift-like initializers
extension UIAlertAction {
    
    static func cancel(_ title: String = NSLocalizedString("Cancel", comment: ""), handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: .cancel, handler: handler)
    }
    
    static func ok(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return self.cancel(NSLocalizedString("OK", comment: ""), handler: handler)
    }
    
    static func dismiss(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return self.cancel(NSLocalizedString("Dismiss", comment: ""), handler: handler)
    }
    
    static func normal(_ title: String, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default, handler: handler)
    }
    
    static func destructive(_ title: String, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: .destructive, handler: handler)
    }
    
    static func delete(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: handler)
    }
    
    // Allow being accessed as properties:
    
    static var cancel: UIAlertAction {
        return .cancel()
    }
    
    static var ok: UIAlertAction {
        return .ok()
    }
    
    static var dismiss: UIAlertAction {
        return .dismiss()
    }
    
    static var delete: UIAlertAction {
        return .delete()
    }
    
}
