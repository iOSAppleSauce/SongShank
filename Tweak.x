#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

#define PREF_DOMAIN CFSTR("cum.over.songshank")

static BOOL P_Enabled = YES;
static void SSLoadPrefs(void){
    CFPropertyListRef v = CFPreferencesCopyAppValue(CFSTR("Enabled"), PREF_DOMAIN);
    P_Enabled = v ? CFBooleanGetValue(v) : YES;
    if (v) CFRelease(v);
}

static BOOL SSHostIsMusic(NSString *h){
    if(!h) return NO;
    h = h.lowercaseString;
    if([h hasSuffix:@".bandcamp.com"]) return YES;
    static NSArray *HOSTS; static dispatch_once_t once;
    dispatch_once(&once, ^{
        HOSTS=@[@"open.spotify.com",@"music.apple.com",
                @"youtu.be",@"www.youtube.com",@"music.youtube.com",
                @"tidal.com",@"www.tidal.com",
                @"deezer.com",@"www.deezer.com",
                @"soundcloud.com",@"m.soundcloud.com",
                @"bandcamp.com"];
    });
    for(NSString *t in HOSTS) if([h isEqualToString:t]) return YES;
    return NO;
}
static BOOL SSIsUniversal(NSURL *u){
    NSString *h=u.host.lowercaseString?:@"";
    return [h isEqualToString:@"song.link"] || [h isEqualToString:@"www.song.link"]
        || [h isEqualToString:@"songwhip.com"] || [h isEqualToString:@"www.songwhip.com"];
}
static NSString* SSEnc(NSString *s){
    return [s stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}
static NSString* SSCountry(void){
    NSString *c = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    return (c.length==2)? c : @"US";
}

static void SSConvert(NSString *src, void(^done)(NSString*)){
    if(!src.length){ done(nil); return; }
    NSURL *u=[NSURL URLWithString:src]; if(!u||SSIsUniversal(u)||!SSHostIsMusic(u.host)){ done(nil); return; }

    NSString *api=[NSString stringWithFormat:@"https://api.song.link/v1-alpha.1/links?userCountry=%@&url=%@",SSCountry(),SSEnc(src)];
    NSURLSessionConfiguration *cfg=[NSURLSessionConfiguration ephemeralSessionConfiguration];
    cfg.timeoutIntervalForRequest=5.0; cfg.timeoutIntervalForResource=5.0;
    cfg.HTTPAdditionalHeaders=@{@"Accept":@"application/json"};
    NSURLSession *session=[NSURLSession sessionWithConfiguration:cfg];
    [[session dataTaskWithURL:[NSURL URLWithString:api]
            completionHandler:^(NSData *data, NSURLResponse *r, NSError *e){
        NSString *fallback=[NSString stringWithFormat:@"https://songwhip.com/?url=%@",SSEnc(src)];
        if(e||!data){ done(fallback); return; }
        id j=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *page=([j isKindOfClass:[NSDictionary class]]) ? j[@"pageUrl"] : nil;
        done(page.length? page: fallback);
    }] resume];
}

static NSInteger gLast=-1; static BOOL gBusy=NO;

static NSString* SSBestPB(UIPasteboard *pb){
    if(pb.URLs.count){ NSURL *u=pb.URLs.firstObject; if(u.absoluteString.length) return u.absoluteString; }
    if(pb.string.length) return pb.string;
    for(NSDictionary *it in pb.items){
        id v=it[@"public.url"];  if([v isKindOfClass:[NSURL class]]) return [(NSURL*)v absoluteString];
        if([v isKindOfClass:[NSString class]]) return (NSString*)v;
        v=it[@"public.text"];    if([v isKindOfClass:[NSString class]]) return (NSString*)v;
    }
    return nil;
}

static void SSProcessPB(void){
    if(!P_Enabled || gBusy) return;
    UIPasteboard *pb=[UIPasteboard generalPasteboard];
    NSInteger seen=pb.changeCount; if(seen==gLast) return;
    gBusy=YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.18*NSEC_PER_SEC)),dispatch_get_main_queue(),^{
        NSString *s=SSBestPB(pb);
        NSURL *u=[NSURL URLWithString:s];
        if(!s||!u||SSIsUniversal(u)||!SSHostIsMusic(u.host)){
            gBusy=NO; gLast=pb.changeCount; return;
        }
        SSConvert(s, ^(NSString *out){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(out.length && ![out isEqualToString:s]) pb.string=out;
                gBusy=NO; gLast=pb.changeCount?:seen+1;
            });
        });
    });
}

%ctor {
    SSLoadPrefs();
    gLast=[UIPasteboard generalPasteboard].changeCount;

    [[NSNotificationCenter defaultCenter] addObserverForName:UIPasteboardChangedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(__unused NSNotification *n){ SSProcessPB(); }];
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,
        ^(CFNotificationCenterRef, void*, CFStringRef, const void*, CFDictionaryRef){ SSLoadPrefs(); },
        CFSTR("com.apple.preferences.changed.cum.over.songshank"),
        NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
