//
//  SearchViewController.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 24/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "SearchViewController.h"
#import "Objection.h"
#import "InstagramMediaItemsModel.h"
#import "MediaFeedViewController.h"

@interface SearchViewController ()

@property (nonatomic, strong) id<InstagramMediaItemsModel> itemsModel;

@property (nonatomic, weak) IBOutlet UITextField *searchField;

@end

@implementation SearchViewController
objection_register(SearchViewController)
objection_requires(@"itemsModel")

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JSObjection defaultInjector] injectDependencies:self];
}

#pragma mark - Private

#pragma mark - Actions

- (IBAction)searchAction:(id)sender {
    [self.itemsModel loadNextPageForSearchString:self.searchField.text];
}

- (IBAction)nextAction:(id)sender {
    MediaFeedViewController *mediaFeedVC = [[MediaFeedViewController alloc] initWithNibName:@"MediaFeedViewController" bundle:nil];
    
    [self presentViewController:mediaFeedVC animated:YES completion:nil];
}

@end
