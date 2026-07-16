abstract class INavigationService {
  void navigateTo(String routeName, {Map<String, dynamic>? arguments});
  void navigateBack();
  void navigateReplace(String routeName, {Map<String, dynamic>? arguments});
  void navigateToRoot();
  Future<T?> navigateToAndWait<T>(String routeName, {Map<String, dynamic>? arguments});
}