//
//  CustomFilterViewController.h
//  Dwell
//
//  Created by Ranosys on 16/09/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//


@protocol CustomFilterDelegate <NSObject>
@optional
- (void) customFilterDelegateAction:(int)status;
- (void) OncallDelegateMethod;
@end
@interface CustomFilterViewController : UIViewController{
    id <CustomFilterDelegate> _delegate;
}
@property (nonatomic,strong) id delegate;

@property (strong, nonatomic) IBOutlet UIView *filterContainverView;
@property (strong, nonatomic) NSMutableDictionary *filterDict;
@property (assign, nonatomic) BOOL isAllSelected;
@property (strong, nonatomic) NSMutableArray *filterArray;
@end
