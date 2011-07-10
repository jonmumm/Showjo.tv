$(document).ready(function(){
    LR.lrInstance = new LrInstance('launchrock',{
        refCodeUrl: "http://showjo.tv/?ref=",
        lrDomain: "showjo.tv",
        apiKey: "ad9b2a7ed0a0626a7573a31cf6635f6e",
        inviteList: "Launching soon. Enter your email to join our invite list:"
    });        

    // Handles events related to signup form, form validations
    // and submitting the form to the server:
    LR.signupForm = new SignupForm({
        secondaryPostLocation: ""
    });


    // Handles rendering the post submit content:
    LR.postSubmit = new PostSignupForm('pagesubmit',{
        twitterHandle: "showjotv",
        twitterMessage: "ShowjoTV is launching soon and I'm one of the first in line! Join me. #launch",
        newUserHeaderText: "",
        newUserParagraphText: "<br/><br/>To share with your friends, click 'Recommend', 'Tweet' and 'Invite by Email':",
        newUserParagraphText3: "",
        returningUserHeaderText: "Welcome Back!",
        returningUserParagraphText: "<br/><br/>To share with your friends, click 'Recommend', 'Tweet' and 'Invite by Email':",
        returningUserParagraphText3: "",
        statsPreText: "Your live stats: ",
        footerLinks: "<a href='http://twitter.com/showjotv'>Follow Us on Twitter</a> | <a href='http://showjotv'>Like Us on Facebook</a>"
,showDescription: true,
showTagLine: true,
showHeaderText: true,
showParagraphText: true,
showStats: true,
showShareButtons: true,
showFooterLinks: true    });


});