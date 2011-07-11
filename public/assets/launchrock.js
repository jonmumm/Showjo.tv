$(document).ready(function(){
    LR.lrInstance = new LrInstance('launchrock',{
        refCodeUrl: "http://showjo.tv/?ref=",
        lrDomain: "showjo.tv",
        apiKey: "ad9b2a7ed0a0626a7573a31cf6635f6e",
        inviteList: "Sign up to know when new things are happenin':"
    });        

    // Handles events related to signup form, form validations
    // and submitting the form to the server:
    LR.signupForm = new SignupForm({
        secondaryPostLocation: ""
    });


    // Handles rendering the post submit content:
    LR.postSubmit = new PostSignupForm('pagesubmit',{
        twitterHandle: "showjotv",
        twitterMessage: "ShowjoTV is an online open mic and is in beta. It's pretty awesome -- try it out.",
        newUserHeaderText: "Thanks for signing up",
        newUserParagraphText: "We'll let you know when new things are happenin'",
        newUserParagraphText3: "Let your friends know what's goin' on.",
        returningUserHeaderText: "Welcome Back!",
        returningUserParagraphText: "We'll let you know when new things are happenin'",
				returningUserParagraphText3: "Let your friends know what's goin' on.",
        footerLinks: "<a href='http://twitter.com/showjotv'>Follow Us on Twitter</a>"
,showDescription: false,
showTagLine: false,
showHeaderText: true,
showParagraphText: true,
showStats: false,
showShareButtons: true,
showFooterLinks: true    });


});