//
//  ImageDownloader.m
//  TableImageDownload
//
//  Created by wildyao on 14/12/18.
//  Copyright (c) 2014年 Wild Yaoyao. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()

@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) PhotoRecord *photoRecord;

@end


@implementation ImageDownloader

#pragma mark -
#pragma mark - Life Cycle

- (id)initWithPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath delegate:(id<ImageDownloaderDelegate>)theDelegate
{
    if (self = [super init]) {
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.photoRecord = record;
    }
    return self;
}

#pragma mark - 
#pragma mark - Downloading image

- (void)main
{
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }
        
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.photoRecord.URL];
        
        if (self.isCancelled) {
            imageData = nil;
            return;
        }
        
        if (imageData) {
            UIImage *downloadedImage = [UIImage imageWithData:imageData];
            self.photoRecord.image = downloadedImage;
        } else {
            self.photoRecord.failed = YES;
        }
        
        imageData = nil;
        
        if (self.isCancelled) {
            return;
        }
        
        // waitUntilDone = YES, 当@selector方法执行完成后再执行接下来的部分
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderDidFinish:) withObject:self waitUntilDone:NO
         ];
    }
}

@end
