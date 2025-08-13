\
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <spawn.h>
extern char **environ;

@interface SSRootListController : PSListController
@end

@implementation SSRootListController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}
- (void)respring {
    pid_t pid;
    const char *tool = "/usr/bin/sbreload";
    const char *argv[] = { tool, NULL };
    posix_spawn(&pid, tool, NULL, NULL, (char * const*)argv, environ);
}
@end
