//
//  ProfileViewModel.swift
//  Whale
//
//  Created by Eliel A. Gordon on 3/12/17.
//  Copyright © 2017 Eliel A. Gordon. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ProfileViewModel {
    let dataSource = SectionedDataSource<ProfileSectionModel>()
    let queue = OperationQueue()
    let downloadOp = Operation()
    var userViewModel: UserProfileCellViewModel?
    weak var delegate: ViewModelDidComplete?
    let synchronizer = WhaleSynchronizer(apiClient: CoreApiClient.me)
    
    init() {
        
        let fetchRequest = NSFetchRequest<User>(entityName: User.entityName)
        fetchRequest.fetchLimit = 1
        let sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let userVM = self.userViewModel
        guard let user = try! synchronizer.coreDataClient.viewContext.fetch(fetchRequest).first else {return}
        
        let userViewModel = UserProfileCellViewModel(
            name: "\(user.firstName) \(user.lastName)",
            email: user.email,
            followCount: "\(user.followerCount) followers    \(user.followingCount) following",
            imageURL: URL(string: user.profileImageURL ?? "")
        )
        
        let section = ProfileSectionModel(header: "Profile", items: [userViewModel])
        self.dataSource.setSections([section])
        
        DispatchQueue.main.async {
            self.delegate?.didCompleteLoading()
        }
        
        dataSource.configureCell = { dataSource, cv, indexPath, cellItem in
            
            let cell = cv.dequeueReusableCell(forIndexPath: indexPath) as UserProfileCell
            
            cell.userProfileCellViewModel = cellItem
            
            return cell
            
        }
        
        dataSource.supplementaryViewFactory = { dataSource, cv, kind, indexPath in
            switch kind {
            case UICollectionElementKindSectionHeader:
                let header = cv.dequeueReusableCell(forIndexPath: indexPath) as UserProfileCell
                header.userProfileCellViewModel = userVM
                return header
            default:
                return UICollectionViewCell()
            }
        }
    }
}
