//
//  PendingOperations.m
//  TableImageDownload
//
//  Created by wildyao on 14/12/18.
//  Copyright (c) 2014年 Wild Yaoyao. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations

- (NSMutableDictionary *)downloadsInProgress
{
    if (!_downloadsInProgress) {
        _downloadsInProgress = [[NSMutableDictionary alloc] init];
    }
    return _downloadsInProgress;
}

- (NSOperationQueue *)downloadQueue
{
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.name = @"Download Queue";
        _downloadQueue.maxConcurrentOperationCount = 1;
    }
    return _downloadQueue;
}

- (NSMutableDictionary *)filtrationsInProgress {
    if (!_filtrationsInProgress) {
        _filtrationsInProgress = [[NSMutableDictionary alloc] init];
    }
    return _filtrationsInProgress;
}

- (NSOperationQueue *)filtrationQueue {
    if (!_filtrationQueue) {
        _filtrationQueue = [[NSOperationQueue alloc] init];
        _filtrationQueue.name = @"Image Filtration Queue";
        _filtrationQueue.maxConcurrentOperationCount = 1;
    }
    return _filtrationQueue;
}

@end
