//
//  MyCollectionFlowLayout.swift
//  VirtualTourist
//
//  Created by Christopher Johnson on 11/22/15.
//  Copyright © 2015 Christopher Johnson. All rights reserved.
//
import UIKit

//modified slightly from :
//http://www.raywenderlich.com/78550/beginning-ios-collection-views-swift-part-1


extension PhotoAlbumViewController : UICollectionViewDelegateFlowLayout {
    //MARK:TODO : update this when we download the photos into their own array (in Documents folder I guess)
//    func collectionView(collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//            
//            let dlPhoto =  currPin!.photos[indexPath.row]
//
//            if var size = dlPhoto.thumbnail?.size {
//                size.width += 10
//                size.height += 10
//                return size
//            }
//            return CGSize(width: 100, height: 100)
//    }
}