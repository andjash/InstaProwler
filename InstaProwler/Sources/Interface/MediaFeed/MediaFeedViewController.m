//
//  MediaFeedViewController.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 27/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "MediaFeedViewController.h"
#import "InstagramMediaItemsModel.h"
#import "Objection.h"
#import "MediaFeedCell.h"
#import "NotificationHandler.h"

#import "UIView+Additions.h"
#import "NSError+Additions.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@interface MediaFeedViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, weak) id<InstagramMediaItemsModel> mediaItemsModel;

@property (nonatomic, strong) NotificationHandler *modelLoadingHandler;
@property (nonatomic, strong) NSDateFormatter *creationDateFormatter;

@end

@implementation MediaFeedViewController
objection_register(MediaFeedViewController)
objection_requires(@"mediaItemsModel")


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
    
    self.creationDateFormatter = [[NSDateFormatter alloc] init];
    [self.creationDateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSString *cellClassName = NSStringFromClass([MediaFeedCell class]);
    [self.tableView registerNib:[UINib nibWithNibName:cellClassName bundle:nil]
         forCellReuseIdentifier:cellClassName];
    
    __weak typeof(self) wself = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [wself.mediaItemsModel loadNextPage];
    }];
    self.tableView.infiniteScrollingView.enabled = [wself.mediaItemsModel hasMoreItems];
    
    self.modelLoadingHandler = [NotificationHandler handlerWithBlock:^(NSNotification *notification) {
        if (wself.mediaItemsModel.state != InstagramMediaItemsModelStateProgress) {
            [wself.tableView reloadData];
            [wself.tableView.infiniteScrollingView stopAnimating];
            wself.tableView.infiniteScrollingView.enabled = [wself.mediaItemsModel hasMoreItems];
        } else {
             [wself.tableView.infiniteScrollingView startAnimating];
        }
    } forNotification:kInstagramMediaItemsModelStateChangedNotification fromObject:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.mediaItemsModel mediaItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellClassName = NSStringFromClass([MediaFeedCell class]);
    MediaFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:cellClassName];
    cell.dateFormatter = self.creationDateFormatter;
    cell.mediaItem = [self.mediaItemsModel mediaItems][indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MediaFeedCell heightWithItem:[self.mediaItemsModel mediaItems][indexPath.row]];
}


@end
