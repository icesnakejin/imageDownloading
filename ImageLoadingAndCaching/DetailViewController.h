//
//  DetailViewController.h
//  ImageLoadingAndCaching
//
//  Created by Yankun Jin on 11/28/16.
//  Copyright © 2016 Yankun Jin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OperationManager.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) Record *record;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstrant;


@end

