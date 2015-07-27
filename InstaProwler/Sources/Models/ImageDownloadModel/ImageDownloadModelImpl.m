//
//  ImageDownloadModelImpl.m
//  InstaProwler
//
//  Created by Andrey Yashnev on 27/07/15.
//  Copyright (c) 2015 Andrey Yashnev. All rights reserved.
//

#import "ImageDownloadModelImpl.h"
#import "Objection.h"
#import "HttpService.h"

@interface ImageDownloadModelImpl ()

@property (nonatomic, strong) NSMutableDictionary *urlToTicketMapping;
@property (nonatomic, weak) id<HttpService> httpService;

@end

@implementation ImageDownloadModelImpl
objection_register_singleton(ImageDownloadModelImpl)
objection_requires(@"httpService")

#pragma mark - Objection

- (void)awakeFromObjection {
    [super awakeFromObjection];
    self.urlToTicketMapping = [NSMutableDictionary dictionary];
}

#pragma mark - Public

- (ImageDownloadProgressTicket *)ticketForUrl:(NSString *)url {
    if (url.length == 0) {
        return nil;
    }
    return self.urlToTicketMapping[url];
}

- (ImageDownloadProgressTicket *)downloadImageForUrl:(NSString *)url {
    ImageDownloadProgressTicket *ticket = [ImageDownloadProgressTicket new];
    ticket.imageUrl = url;
    
    RequestParameters *rp = [RequestParameters new];
    rp.url = [NSURL URLWithString:url];
    rp.method = @"GET";
    
    ExecutionParameters *ep = [ExecutionParameters new];
    
    [ep setSuccessBlock:^(NSData *data) {
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            image = [UIImage imageWithCGImage:image.CGImage
                                        scale:[UIScreen mainScreen].scale
                                  orientation:image.imageOrientation];
        }
        ticket.image = image;
        ticket.progress = 1;
    }];
    
    [ep setErrorBlock:^(NSError *error) {
        ticket.image = nil;
        ticket.progress = 1;
    }];
    
    [ep setProgressBlock:^(double progress) {
        ticket.progress = (float)(progress / 100);
    }];
    
    self.urlToTicketMapping[url] = ticket;
    
    [self.httpService performRequestWithExecutionParameters:ep requestParameters:rp];
    
    return ticket;
}

@end