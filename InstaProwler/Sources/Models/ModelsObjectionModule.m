//
//  ModelsObjectionModule.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 25/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "ModelsObjectionModule.h"
#import "InstagramMediaItemsModelImpl.h"

@implementation ModelsObjectionModule

#pragma mark - JSObjectionModule

- (void)configure {
    [self bindClass:[InstagramMediaItemsModelImpl class] toProtocol:@protocol(InstagramMediaItemsModel)];
}

@end
