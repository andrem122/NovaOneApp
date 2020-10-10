//
//  CustomerUserPushNotificationTokens.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 10/9/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

struct CustomerUserPushNotificationTokens: Decodable {

    // MARK: Properties
    var id: Int
    var deviceToken: String
    var created: String
    var type: String
    var customerUserId: Int
    var applicationBadgeCount: Int
    var newAppointmentCount: Int
    var newLeadCount: Int
}

