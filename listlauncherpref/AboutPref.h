//#import <Preferences/PSListController.h>
//#include <Preferences/Preferences.h>
#import <CoreFoundation/CoreFoundation.h>
#import "Preferences.h"

@interface MoreTweaksController : PSListController {
}
@end

@interface AboutListLauncherController : PSListController
@end


@interface CreditCellClass : PSTableCell <UITextViewDelegate> { 
	UITextView *_plainTextView;
}
@end


