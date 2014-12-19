//
//  ListViewController.h
//  TableImageDownload
//
//  Created by wildyao on 14/12/18.
//  Copyright (c) 2014年 Wild Yaoyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoRecord.h"
#import "PendingOperations.h"
#import "ImageDownloader.h"
#import "ImageFiltration.h"

@interface ListViewController : UITableViewController <ImageDownloaderDelegate, ImageFiltrationDelegate>

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) PendingOperations *pendingOperations;

@end
