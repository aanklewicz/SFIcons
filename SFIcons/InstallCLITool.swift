//
//  InstallCLITool.swift
//  SFIcons
//
//  Created by Adam Anklewicz on 2024-12-30.
//  Copyright © 2024 Adam Anklewicz. All rights reserved.
//


import SwiftUI
import Foundation

class InstallCLITool: NSMenuItem {
    override init(title string: String, action selector: Selector?, keyEquivalent charCode: String) {
        super.init(title: string, action: selector, keyEquivalent: charCode)
        self.target = self
        self.action = #selector(installCLI)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func installCLI() {
        // Get the path to the app bundle
        let appBundlePath = Bundle.main.bundlePath as String

        // Construct the CLI tool path
        let cliPath = "\(appBundlePath)/Contents/SharedSupport/sficons"
        let aliasPath = "/usr/local/bin/sficons"

        // 1. Check for existing alias
        if FileManager.default.fileExists(atPath: aliasPath) && isAlias(atPath: aliasPath) {
            showAlert(message: "CLI Tool already installed.")
            return
        }

        // 2. Check for existing file
        if FileManager.default.fileExists(atPath: aliasPath) {
            showAlert(message: "There is another file called 'sficons' already installed. Cancelling install.")
            return
        }

        // 3. Request Authorization to run with elevated privileges
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        task.arguments = ["ln", "-s", cliPath, aliasPath]

        // Set up Authorization Rights
        let authRef = authorizationCreate()

        if let authRef = authRef {
            task.environment = ["PATH": "/usr/bin:/bin:/usr/sbin:/sbin"]
            task.standardOutput = Pipe()
            task.standardError = task.standardOutput

            do {
                try task.run()
                task.waitUntilExit()
                if task.terminationStatus == 0 {
                    showAlert(message: "CLI Tool successfully installed.")
                } else {
                    showAlert(message: "Error installing CLI Tool.")
                }
            } catch {
                showAlert(message: "Error running task: \(error.localizedDescription)")
            }
        } else {
            showAlert(message: "Unable to request elevated privileges.")
        }
    }

    func authorizationCreate() -> AuthorizationRef? {
        var authRef: AuthorizationRef?
        let status = AuthorizationCreate(nil, nil, [], &authRef)

        if status == errAuthorizationSuccess {
            return authRef
        } else {
            return nil
        }
    }

    func isAlias(atPath path: String) -> Bool {
        do {
            let resourceValues = try URL(fileURLWithPath: path).resourceValues(forKeys: [.isAliasFileKey])
            return resourceValues.isAliasFile ?? false
        } catch {
            print("Error checking alias: \(error.localizedDescription)")
            return false
        }
    }

    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
