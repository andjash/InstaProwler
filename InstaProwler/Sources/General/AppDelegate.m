//
//  AppDelegate.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 24/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "AppDelegate.h"
#import "SearchViewController.h"
#import "Objection.h"
#import "ServicesObjectionModule.h"
#import "ModelsObjectionModule.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupObjection];
    [self setupViewControllers];
    return YES;
}


#pragma mark - Private

- (void)setupViewControllers {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    SearchViewController *searchVC = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    self.window.rootViewController = searchVC;
    [self.window makeKeyAndVisible];
}

- (void)setupObjection {
    NSArray *modules = @[[ServicesObjectionModule new], [ModelsObjectionModule new]];
    JSObjectionInjector *container = [JSObjection createInjectorWithModulesArray:modules];
    [JSObjection setDefaultInjector:container];
    [[JSObjection defaultInjector] injectDependencies:self];
}

@end
