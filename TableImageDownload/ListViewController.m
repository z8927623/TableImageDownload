//
//  ListViewController.m
//  TableImageDownload
//
//  Created by wildyao on 14/12/18.
//  Copyright (c) 2014年 Wild Yaoyao. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()

@end

@implementation ListViewController

#pragma mark -
#pragma mark - Lazy instantiation


- (PendingOperations *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}

- (NSMutableArray *)photos
{
    if (!_photos) {
        NSMutableArray *records = [NSMutableArray array];
        NSArray *urlArray = [NSArray arrayWithObjects:@"http://ww1.sinaimg.cn/bmiddle/677e4af2jw1ene1d32p4tj20gi0azmzq.jpg", @"http://ww2.sinaimg.cn/thumbnail/c1452114jw1ene19xwwooj20c80gf755.jpg", @"http://ww2.sinaimg.cn/square/005S2wnXgw1endywhjmr2j30h80bcdhv.jpg", @"http://ww4.sinaimg.cn/square/9077b22dgw1ene14xmksqj20e10e0q3d.jpg", @"http://ww1.sinaimg.cn/thumbnail/78f2cc43gw1endgy0g3vaj20bu09a0tz.jpg", @"http://ww4.sinaimg.cn/square/638aabf9gw1ene068u4zej20c5092t9h.jpg", @"http://ww1.sinaimg.cn/square/6961aadegw1endmowd59sj20aa2720zm.jpg", @"http://ww3.sinaimg.cn/thumbnail/745c99aegw1endw4cdtm6j20c80u7tgm.jpg", @"http://ww3.sinaimg.cn/thumbnail/89c9a84fgw1endl3uqqwrj20b40ezac9.jpg", @"http://ww4.sinaimg.cn/square/005HUPOpjw1ene079s8e0j30sg0mrgpf.jpg", @"http://ww1.sinaimg.cn/square/6d38ee54jw1endyq7i4lqj20c80ic0uh.jpg", @"http://ww2.sinaimg.cn/thumbnail/680e28b8jw1endj93krr2j20ri6heb29.jpg", @"http://ww3.sinaimg.cn/thumbnail/591993d0gw1enci0cdsefj20ca096my7.jpg", @"http://ww3.sinaimg.cn/thumbnail/b28db48cjw1endubzkrxfj20c80kajta.jpg", @"http://ww3.sinaimg.cn/thumbnail/ba1eb447jw1endz0tke8yj21100u07aw.jpg", @"http://ww1.sinaimg.cn/bmiddle/c0742d06gw1endzuotuifj20gd0dy776.jpg", @"http://ww3.sinaimg.cn/thumbnail/8a0f1667jw1ene011q9r3j20ad0fkgo3.jpg", @"http://ww4.sinaimg.cn/thumbnail/97a4d66ejw1endznic0dlj209r074q2y.jpg", @"http://ww3.sinaimg.cn/thumbnail/77689455jw1endzzta6ykj20e60l9q33.jpg", @"http://ww2.sinaimg.cn/thumbnail/76d31618gw1endzsx7xzhj20hs0hstb7.jpg", nil];
       
        for (int i = 0; i < 20; i++) {
            PhotoRecord *record = [[PhotoRecord alloc] init];
            record.URL = [NSURL URLWithString:urlArray[i]];
            record.name = [NSString stringWithFormat:@"image %d", i];
            [records addObject:record];
        }
        
        self.photos = records;
    }
    return _photos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Classic Photos";
    self.tableView.rowHeight = 80.0;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.photos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cell.accessoryView = activityIndicatorView;
    
    
    PhotoRecord *aRecord = [self.photos objectAtIndex:indexPath.row];
    
    if (aRecord.hasImage) {
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.imageView.image = aRecord.image;
        cell.textLabel.text = aRecord.name;
    } else if (aRecord.isFailed) {
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Failed.png"];
        cell.textLabel.text = @"Failed to load";
    } else {
        
        [((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        cell.textLabel.text = @"";
        
        if (!tableView.dragging && !tableView.decelerating)  {
            [self startOperationsForPhotoRecord:aRecord atIndexPath:indexPath];
        }
    }
    
    return cell;
}

- (void)startOperationsForPhotoRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath
{
    if (!record.hasImage) {
        [self startImageDownloadingForRecord:record atIndexPath:indexPath];
    }
    
    if (!record.isFiltered) {
        [self startImageFiltrationForRecord:record atIndexPath:indexPath];
    }
}

- (void)startImageDownloadingForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath
{
    if (![self.pendingOperations.downloadsInProgress.allKeys containsObject:indexPath]) {
        ImageDownloader *imageDownloader = [[ImageDownloader alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        [self.pendingOperations.downloadsInProgress setObject:imageDownloader forKey:indexPath];
        [self.pendingOperations.downloadQueue addOperation:imageDownloader];
    }
}

- (void)startImageFiltrationForRecord:(PhotoRecord *)record atIndexPath:(NSIndexPath *)indexPath
{
    if (![self.pendingOperations.filtrationsInProgress.allKeys containsObject:indexPath]) {
       ImageFiltration *imageFiltration = [[ImageFiltration alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
        ImageDownloader *dependency = [self.pendingOperations.downloadsInProgress objectForKey:indexPath];
        if (dependency) {
            // 添加依赖，在下载完成之后再添加滤镜
            [imageFiltration addDependency:dependency];
        }
        
        [self.pendingOperations.filtrationsInProgress setObject:imageFiltration forKey:indexPath];
        [self.pendingOperations.filtrationQueue addOperation:imageFiltration];
    }
}

#pragma mark -
#pragma mark - ImageDownloader delegate

- (void)imageDownloaderDidFinish:(ImageDownloader *)downloader
{
    NSIndexPath *indexPath = downloader.indexPathInTableView;
    PhotoRecord *theRecord = downloader.photoRecord;
    
    [self.photos replaceObjectAtIndex:indexPath.row withObject:theRecord];
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.pendingOperations.downloadsInProgress removeObjectForKey:indexPath];
}

#pragma mark -
#pragma mark - ImageFiltration delegate

- (void)imageFiltrationDidFinish:(ImageFiltration *)filtration
{
    NSIndexPath *indexPath = filtration.indexPathInTableView;
    PhotoRecord *theRecord = filtration.photoRecord;
    
    [self.photos replaceObjectAtIndex:indexPath.row withObject:theRecord];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.pendingOperations.filtrationsInProgress removeObjectForKey:indexPath];
}

#pragma mark -
#pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 拖拽的时候暂停所有operation
    [self suspendAllOperations];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 停止拖拽还没开始减速
    
    if (!decelerate) {
        // 取消屏幕以外的cell的操作，开始屏幕内cell的操作
        [self loadImageForOnScreenCells];
        // 继续所有operation
        [self resumeAllOperations];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 停止滚动
    
    // 取消屏幕以外的cell的操作，开始屏幕内cell的操作
    [self loadImageForOnScreenCells];
    // 继续所有operation
    [self resumeAllOperations];
}

#pragma mark -
#pragma mark - Cancelling, suspending, resuming queues / operations

- (void)suspendAllOperations
{
    [self.pendingOperations.downloadQueue setSuspended:YES];
    [self.pendingOperations.filtrationQueue setSuspended:YES];
}

- (void)resumeAllOperations
{
    [self.pendingOperations.downloadQueue setSuspended:NO];
    [self.pendingOperations.filtrationQueue setSuspended:NO];
}

- (void)cancelAllOperations
{
    [self.pendingOperations.downloadQueue cancelAllOperations];
    [self.pendingOperations.filtrationQueue cancelAllOperations];
}

// 取消屏幕以外的cell的操作，开始屏幕内cell的操作
- (void)loadImageForOnScreenCells
{
    // 获取可见行
    NSSet *visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    // 获取所有正在下载或正在过滤的行
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.downloadsInProgress allKeys]];
    [pendingOperations addObjectsFromArray:[self.pendingOperations.filtrationsInProgress allKeys]];
    
    // 所有正在操作的cell的indexPath
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    // 屏幕内要开始操作cell的indexPath
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    
    // 去除toBeStarted在pendingOperations里的元素
    // 即可见行减去正在操作的行，即是即将操作的行
    [toBeStarted minusSet:pendingOperations];
    // 去除toBeCancelled在visibleRows里的元素
    // 即所有正在操作的行减去可见行，即是要取消操作的行
    [toBeCancelled minusSet:visibleRows];
    
    for (NSIndexPath *anIndexPath in toBeCancelled) {
        ImageDownloader *pendingDownload = [self.pendingOperations.downloadsInProgress objectForKey:anIndexPath];
        [pendingDownload cancel];
        [self.pendingOperations.downloadsInProgress removeObjectForKey:anIndexPath];
        
        ImageFiltration *pendingFiltration = [self.pendingOperations.filtrationsInProgress objectForKey:anIndexPath];
        [pendingFiltration cancel];
        [self.pendingOperations.filtrationsInProgress removeObjectForKey:anIndexPath];
    }
    toBeCancelled = nil;
    
    for (NSIndexPath *anIndexPath in toBeStarted) {
        PhotoRecord *recordToProcess = [self.photos objectAtIndex:anIndexPath.row];
        [self startOperationsForPhotoRecord:recordToProcess atIndexPath:anIndexPath];
    }
    
    toBeStarted = nil;
}

@end
