

import 'package:flutter/foundation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:stylestore/controllers/homepage_controller.dart';
import 'package:stylestore/controllers/task_controller.dart';
import 'package:stylestore/controllers/transactions_controller.dart';
import 'package:stylestore/screens/MobileMoneyPages/make_payment_page.dart';
import 'package:stylestore/screens/MobileMoneyPages/mobile_money_page.dart';
import 'package:stylestore/screens/analytics/loading_analysis_page.dart';
import 'package:stylestore/screens/change_store_photo.dart';
import 'package:stylestore/screens/customer_care_page.dart';
import 'package:stylestore/screens/Documents_Pages/documents.dart';
import 'package:stylestore/screens/documents.dart';
import 'package:stylestore/screens/employee_pages/biodata_page_1.dart';
import 'package:stylestore/screens/employee_pages/employees_page.dart';
import 'package:stylestore/screens/expenses_pages/expenses.dart';
import 'package:stylestore/screens/home_pages/home_page_web.dart';
import 'package:stylestore/screens/products_pages/product_edit_page.dart';
import 'package:stylestore/model/styleapp_data.dart';
import 'package:stylestore/screens/Messages/message_history.dart';
import 'package:stylestore/screens/addBlog.dart';
import 'package:stylestore/screens/customer_pages/add_customers_page.dart';
import 'package:stylestore/screens/add_service.dart';
import 'package:stylestore/screens/addProduct.dart';
import 'package:stylestore/screens/addRecipe.dart';
import 'package:stylestore/screens/add_trend.dart';
import 'package:stylestore/screens/business_registration.dart';
import 'package:stylestore/screens/chart_pages/stock_management_page.dart';
import 'package:stylestore/screens/customer_pages/customer_transactions.dart';
import 'package:stylestore/screens/customer_pages/customers_page.dart';
import 'package:stylestore/screens/edit_page.dart';
import 'package:stylestore/screens/Messages/message.dart';
import 'package:stylestore/screens/payment_pages/pos2.dart';
import 'package:stylestore/screens/products_pages/products_upload.dart';
import 'package:stylestore/screens/products_pages/restock_page.dart';
import 'package:stylestore/screens/products_pages/stock_history.dart';
import 'package:stylestore/screens/products_pages/update_stock.dart';
import 'package:stylestore/screens/employee_pages/edit_employee_profile_page.dart';
import 'package:stylestore/screens/reviews_page.dart';
import 'package:stylestore/screens/sign_in_options/employee_sign_in.dart';
import 'package:stylestore/screens/sign_in_options/logi_new_layout_web.dart';
import 'package:stylestore/screens/sign_in_options/sign_in_page.dart';
import 'package:stylestore/screens/sign_in_options/signup_page.dart';
import 'package:stylestore/screens/store_setup.dart';
import 'package:stylestore/screens/suppliers/supplier_form.dart';
import 'package:stylestore/screens/suppliers/supplier_page.dart';
import 'package:stylestore/screens/team_pages/team_page.dart';
import 'package:stylestore/screens/transactions_online_page.dart';
import 'package:stylestore/screens/calendar_pages/calendar_page.dart';
import 'package:stylestore/screens/home_pages/home_page_mobile.dart';
import 'package:stylestore/screens/service_edit_page.dart';
import 'package:stylestore/screens/sign_in_options/login_page.dart';
import 'package:stylestore/screens/order_details_page.dart';
import 'package:stylestore/screens/splash_page.dart';
import 'package:stylestore/screens/services_page.dart';
import 'package:stylestore/screens/success_page_appointments.dart';
import 'package:stylestore/screens/transactions_pages/new_transactions_page.dart';
import 'package:stylestore/screens/transactions_products.dart';
import 'package:stylestore/screens/trends_page.dart';
import 'package:stylestore/screens/tutorials_page.dart';
import 'package:stylestore/screens/upload_trend.dart';
import 'package:stylestore/screens/customer_pages/search_customer.dart';
import 'package:stylestore/screens/wallets_page.dart';
import 'package:stylestore/widgets/success_hi_five.dart';
import 'package:stylestore/screens/videos/tutorials_page_new.dart';
import 'controllers/adding_controller.dart';
import 'controllers/delivery_controller.dart';
import 'controllers/home_page_controllers/home_controller_mobile.dart';
import 'controllers/home_page_controllers/home_control_page_web.dart';
import 'controllers/responsive/responsive_page.dart';
import 'controllers/services_controller.dart';
import 'model/beautician_data.dart';
import 'model/translations_model.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDLJj_nZyjAzBdWB5kW91opVds5Ao80XWc",
        appId: "1:406674063138:web:bcbba63e6a56ceedf1af7b",
        messagingSenderId: "406674063138",
        projectId: "doctor-booking-aa868",
        storageBucket: "doctor-booking-aa868.appspot.com",
      ),
    );
  }else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // App received a notification when it was killed
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) {
            return BeauticianData();
          },
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) {
            return StyleProvider();
          },
        ),
      ],
      child: GetMaterialApp(
        locale: Locale('en', 'US'),
        translations: Translation(),
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        //home: WelcomePage(),
        debugShowCheckedModeBanner: false,
        initialRoute: SplashPage.id,

        routes: {
          '/': (context) => SplashPage(),
          HomePage.id: (context) => HomePage(),
          AppointmentSummary.id: (context) => AppointmentSummary(),
          ControlPageMobile.id: (context) => ControlPageMobile(),
          ControlPageWeb.id: (context) => ControlPageWeb(),
          ServicesPage.id: (context) => ServicesPage(),
          LoginPage.id: (context) => LoginPage(),
          ServicesEditPage.id: (context) => ServicesEditPage(),
          AddServicePage.id: (context) => AddServicePage(),
          AddItemsController.id: (context) => AddItemsController(),
          InputProductPage.id: (context) => InputProductPage(),
          ServicesController.id: (context) => ServicesController(),
          SplashPage.id: (context) => SplashPage(),
          AddRecipePage.id: (context) => AddRecipePage(),
          SignInUserPage.id: (context) => SignInUserPage(),
          TransactionsOnlinePage.id: (context) => TransactionsOnlinePage(),
          SuccessPageHiFive.id: (context) => SuccessPageHiFive(),
          AddBlogPage.id: (context) => AddBlogPage(),
          DeliveryController.id: (context) => DeliveryController(),
          TransactionsController.id: (context) => TransactionsController(),
          CalendarPageOld.id: (context) => CalendarPageOld(),
          SuccessPage.id: (context) => SuccessPage(),
          TrendsPage.id: (context) => TrendsPage(),
          AddTrendPage.id: (context) => AddTrendPage(),
          UploadTrendPage.id: (context) => UploadTrendPage(),
          EditShopPage.id: (context) => EditShopPage(),
          POS.id: (context) => POS(),
          HomePageController.id: (context) => HomePageController(),
          ReviewsPage.id: (context) => ReviewsPage(),
          TutorialPage.id: (context) => TutorialPage(),
          TransactionsProducts.id: (context) => TransactionsProducts(),
          ProductEditPage.id: (context) => ProductEditPage(),
          ProductUpload.id: (context) => ProductUpload(),
          CustomerPage.id: (context) => CustomerPage(),
          AddCustomersPage.id: (context) => AddCustomersPage(),
          CustomerSearchPage.id: (context) => CustomerSearchPage(),
          BusinessSignup.id: (context) => BusinessSignup(),
          RegisterPageDuplicate.id: (context) => RegisterPageDuplicate(),
          StoreSetup.id: (context) => StoreSetup(),
          CustomerTransactionsProducts.id: (context) =>
              CustomerTransactionsProducts(),
          TasksController.id: (context) => TasksController(),
          StockManagementPage.id: (context) => StockManagementPage(),
          MessagesPage.id: (context) => MessagesPage(),
          MessageHistoryPage.id: (context) => MessageHistoryPage(),
          NewTransactionsPage.id: (context) => NewTransactionsPage(),
          ReStockPage.id: (context) => ReStockPage(),
          UpdateStockPage.id: (context) => UpdateStockPage(),
          StockHistoryPage.id: (context) => StockHistoryPage(),
          MobileMoneyPage.id: (context) => MobileMoneyPage(),
          NewTutorialPage.id: (context) => NewTutorialPage(),
          CustomerCarePage.id: (context) => CustomerCarePage(),
          ChangeStorePhoto.id: (context) => ChangeStorePhoto(),
          MakePaymentPage.id: (context) => MakePaymentPage(),
          ExpensesPage.id: (context) => ExpensesPage(),
          ExpensesPage.id: (context) => ExpensesPage(),
          LoadingAnalysisPage.id: (context) => LoadingAnalysisPage(),
          EmployeeSignIn.id: (context) => EmployeeSignIn(),
          TeamPage.id: (context) => TeamPage(),
          HomePageWeb.id: (context) => HomePageWeb(),
          LoginPageNewWeb.id: (context) => LoginPageNewWeb(),
          DocumentsPage.id: (context) => DocumentsPage(),
          EmployeesPage.id: (context) => EmployeesPage(),
          SuppliersPage.id: (context) => SuppliersPage(),
          WalletsPage.id: (context) => WalletsPage(),
          BioDataForm.id: (context) => BioDataForm(),
          SupplierForm.id: (context) => SupplierForm(),
          EditProfilePage.id: (context) => EditProfilePage(),
          SuperResponsiveLayout.id: (context) => SuperResponsiveLayout(
              mobileBody: HomePageController(), desktopBody: ControlPageWeb()),
        },
      ),
    );
  }
}
