//
//  DispatchQueue.swift
//  VirtualTourist
//
//  Created by Anan Yousef on 27/01/2021.
//

import Foundation


func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
