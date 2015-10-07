//
//  PassiveTableViewCell.h
//  Store
//
//  Created by Eric Dufresne on 2015-03-26.
//  Copyright (c) 2015 Eric Dufresne. All rights reserved.
//

#import <UIKit/UIKit.h>
//TableViewCell for teir products which uses a UIProgressView to show progress of teir.

@interface PassiveTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UIImageView *coin;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descripionLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *tierSlider;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@end
