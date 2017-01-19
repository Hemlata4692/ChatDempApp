//
//  DashboardViewController.h
//  ChatDemoApp
//
//  Created by Ranosys on 09/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogoutXMPP.h"
#import <CoreData/CoreData.h>

@interface DashboardViewController : LogoutXMPP<NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *fetchedResultsController;
    
}

@end
