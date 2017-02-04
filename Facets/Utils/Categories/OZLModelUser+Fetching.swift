//
//  OZLModelUser+Fetching.swift
//  Facets
//
//  Created by Justin Hill on 1/29/17.
//  Copyright © 2017 Justin Hill. All rights reserved.
//

extension OZLModelUser {
    func updatedUserModel(completion: @escaping (_ user: OZLModelUser?) -> Void) {
        guard let userId = self.userId else {
            completion(nil)
            return
        }
        
        if let user = OZLModelUser(forPrimaryKey: userId) {
            // if the last fetch was less than a week ago, don't fetch again
            if let lastFetchedDate = user.lastFetchedDate, lastFetchedDate > Date().addingTimeInterval(-60 * 60 * 24 * 7) {
                completion(user)
                return
            }
        }

        OZLNetwork.sharedInstance().getUserWithId(userId) { (user, error) in
            do {
                RLMRealm.default().beginWriteTransaction()
                user.userId = userId
                user.lastFetchedDate = Date()
                OZLModelUser.createOrUpdateInDefaultRealm(withValue: user)
                try RLMRealm.default().commitWriteTransaction()
            } catch {
                print("Failed to save the user object to the Realm.")
            }

            completion(user)
        }
    }
}
