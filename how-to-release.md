# How to release

*This guides assumes users has rights to push the `NearUIBinding` pod*

* In the *release* or the *hotfix* branch, edit the `NearUIBinding.podspec` file to update the pod version and, if necessary, the underlying `NearITSDK` pod version.
* Have your version as a tag (on *master*) and push it to github repo, along with the code you wish to publish
* Run `pod trunk push NearUIBinding.podspec --allow-warnings`