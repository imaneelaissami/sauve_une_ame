import 'package:flutter/material.dart';
import 'home_page.dart';
import 'signup.dart';
import 'login_page.dart';
import 'SauveteurUserPage.dart';
import 'AdoptantUserPage.dart';
import 'NormalUserPage.dart';
import 'AdminHomePage.dart';
import 'normal/EditProfileNormalUserPage.dart';
import 'sauveteur/EditProfileSauveteurPage.dart';
import 'ConditionsPage.dart';
import 'adaptant/EditProfileAdoptantPage.dart';
import 'normal/SignalerAnimalPage.dart';
import 'sauveteur/PublierAnimalAdoptionPage.dart';
import 'ConseilsPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sauve Une Ame',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Route spéciale لـ NormalUserPage

        if (settings.name == '/normalUser') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(body: Center(child: Text('Pas de données utilisateur'))),
            );
          }
          return MaterialPageRoute(
            builder: (context) => NormalUserPage(userData: args),
            settings: settings,
          );
        }
        else  if (settings.name == '/sauveteurUser') {
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
        builder: (context) => SauveteurUserPage(
        fullName: args['fullName'] ?? '',
        profileImage: args['profileImage'] ?? '',
        email: args['email'] ?? '',
        phone: args['phone'] ?? '',
        sex: args['sex'] ?? '',
        age: args['age'] ?? '',
        city: args['city'] ?? '',
        country: args['country'] ?? '',
        userType: args['userType'] ?? '',
        ),
        );
        }


        else if (settings.name == '/adoptantUser') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AdoptantUserPage(userData: args),
          );
        }


        // باقي المسارات
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => HomePage());
          case '/editProfileSauveteur':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => EditProfileSauveteurPage(
                fullName: args['fullName'] ?? '',
                profileImage: args['profileImage'] ?? '',
                email: args['email'] ?? '',
                phone: args['phone'] ?? '',
                sex: args['sex'] ?? '',
                age: args['age'] ?? '',
                city: args['city'] ?? '',
                country: args['country'] ?? '',
              ),
            );

          case '/editProfileNormalUser':
            final args = settings.arguments as Map<String, dynamic>?; // args ممكن تكون null
            if (args == null) {
              return MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: Center(child: Text('Pas de données utilisateur')),
                ),
              );
            }


            return MaterialPageRoute(
              builder: (context) => EditProfileNormalUserPage(userData: args),
            );
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/signup':
            return MaterialPageRoute(builder: (context) => SignupPage());
          case '/superadmin':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (context) => AdminHomePage(arguments: args),
            );

          case '/conditions':
            return MaterialPageRoute(builder: (context) => ConditionsPage());


          case '/editProfileAdoptant':  // <-- هادي لازم تكون هنا كحالة مستقلة
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => EditProfileAdoptantPage(userData: args),
            );
          case '/signalerAnimal':
            final args = settings.arguments as Map<String, dynamic>;

            return MaterialPageRoute(
              builder: (context) => SignalerAnimalPage(currentUser: args),
            );



        case '/publierAnimal':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
        builder: (_) => PublierAnimalAdoptionPage(user: args),
        );

          case '/conseils':
            return MaterialPageRoute(builder: (_) => const ConseilsPage());
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(child: Text('Page non trouvée')),
              ),
            );

        }
      },
    );
  }
}
