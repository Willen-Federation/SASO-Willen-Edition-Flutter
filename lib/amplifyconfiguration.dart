// SASO Willen Edition — AWS Amplify configuration stub.
//
// This file is committed as a placeholder and is safe to share publicly
// because it contains no real credentials.
//
// To enable SNS Pinpoint push notifications:
//   1. Create an Amplify project in AWS Console (see docs/setup/amplify.md)
//   2. Replace REPLACE_WITH_YOUR_PINPOINT_APP_ID with your actual Pinpoint App ID
//   3. Update the region if your project is not in ap-northeast-1
//   4. Set ff_push_sns = true via Firebase Remote Config or ServerSettingsPage
//
// WARNING: Never commit real credentials. If you have a real config,
// add lib/amplifyconfiguration.dart to .gitignore and keep it local.
const amplifyconfig = '''
{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "notifications": {
    "plugins": {
      "awsPinpointNotificationsPlugin": {
        "pinpointAnalytics": {
          "appId": "REPLACE_WITH_YOUR_PINPOINT_APP_ID",
          "region": "ap-northeast-1"
        },
        "pinpointTargeting": {
          "region": "ap-northeast-1"
        }
      }
    }
  }
}
''';
