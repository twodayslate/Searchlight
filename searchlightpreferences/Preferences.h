#import <CoreFoundation/CoreFoundation.h>
@interface ALApplicationList : NSObject{
}
+(ALApplicationList *)sharedApplicationList;
@property (nonatomic, readonly) NSDictionary *applications;
- (id)valueForKey:(NSString *)keyPath forDisplayIdentifier:(NSString *)displayIdentifier;
-(NSInteger)applicationCount;
- (UIImage *)iconOfSize:(int)iconSize forDisplayIdentifier:(NSString *)displayIdentifier;
@end

@interface PSViewController : UIViewController
-(void)setPreferenceValue:(id)arg1 specifier:(id)arg2 ;
@end

@interface UIPreferencesTable
@end

@interface PSListController : PSViewController { 
	NSMutableArray* _specifiers; 
	UIPreferencesTable* _table;
}
-(void)loadView;
-(id)loadSpecifiersFromPlistName:(id)arg1 target:(id)arg2 ;
-(void)reloadSpecifier:(id)arg1 ;
-(id)specifierForID:(id)arg1 ;
- (id)table;
-(void)reload;
-(void)reloadSpecifiers;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; 
-(void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 ;
@end

@interface PSSpecifier : NSObject {
	NSMutableDictionary* _properties;
}
+ (id)preferenceSpecifierNamed:(id)arg1 target:(id)arg2 set:(SEL)arg3 get:(SEL)arg4 detail:(id)arg5 cell:(id)arg6 edit:(int)arg7;
-(void)setProperty:(id)property forKey:(NSString*)key;
-(id)identifier;
-(void)setIdentifier:(id)arg1 ;
-(id)properties;
-(void)setProperties:(id)arg1 ;
@end

@interface PSTableCell : UITableViewCell
@property(readonly, assign, nonatomic) UILabel* textLabel;
@property (nonatomic,retain,readonly) UILabel * detailTextLabel; 
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 ;
+(id)cellTypeFromString:arg1;
@end

@interface PSEditableListController  : PSListController
-(void)setEditingButtonHidden:(BOOL)arg1 animated:(BOOL)arg2 ;
-(void)setEditButtonEnabled:(BOOL)arg1 ;
-(id)_editButtonBarItem;
- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
@end

@interface PSSwitchTableCell
-(id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3;
-(id)control;
@end

@interface LLBaseController : PSListController {
	NSArray *_sortedDisplayIdentifiers;
	ALApplicationList *_applicationList;
}
@property (nonatomic, retain) ALApplicationList *applicationList;
@property (nonatomic, retain) NSArray *sortedDisplayIdentifiers;
@end

@interface LLFavoritesController : PSEditableListController <UITableViewDelegate, UITableViewDataSource> {
	NSMutableArray *_favoriteList;
	NSArray *_sortedDisplayIdentifiers;
	ALApplicationList *_applicationList;
}
@property (nonatomic, retain) NSMutableArray *favoriteList;
@property (nonatomic, retain) ALApplicationList *applicationList;
@property (nonatomic, retain) NSArray *sortedDisplayIdentifiers;
@end

@interface LLRecentController : LLBaseController {	
}
@end

@interface LLFavoritesAddController : LLBaseController {
}
@end

@interface LLApplicationController : LLBaseController {
}
@end

@interface SBSearchViewController : UIViewController <UITableViewDataSource>{
}
+(SBSearchViewController *)sharedInstance;
-(NSArray *)sortedDisplayIdentifiers;
-(id)applicationList;
@end


@interface LLTweakListController : PSListController {
}
@end

@interface LLAboutController : PSListController
@end

@interface LLAppearanceController : PSListController
@end

@interface CreditCellClass : PSTableCell <UITextViewDelegate> { 
	UITextView *_plainTextView;
}
@end