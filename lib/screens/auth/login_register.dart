import 'utils/auth_bloc.dart';
import 'package:cysecurity/const/paths.dart';
import 'package:cysecurity/const/variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GoogleSignin extends StatelessWidget {

  void _authenticateWithGoogle(context) {
    BlocProvider.of<AuthBloc>(context).add(
      GoogleSignInRequested(),
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var width = MediaQuery.of(context).size.width;
    return SafeArea(child: Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // Navigating to the dashboard screen if the user is authenticated
            // Navigator.pushReplacement(context,
            //     MaterialPageRoute(builder: (context) => const ApkList()));
          }
          if (state is AuthError) {
            // Showing the error message if the user has entered invalid credentials
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Loading) {
              // Showing the loading indicator while the user is signing in
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is UnAuthenticated) {
              // Showing the sign in form if the user is not authenticated
              return Stack(
                children: [
                  Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: width * 0.2,left: width * 0.2,right: width * 0.2),
                      child: const Text("Darwis App",style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold))
                  ),
                  Container(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.only(bottom: width * 0.2,left: width * 0.2,right: width * 0.2),
                      child: ElevatedButton(
                        onPressed: () => _authenticateWithGoogle(context),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset(Paths.googleIcon,scale: 20),
                              const Text(Variables.googleLogin,style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15
                              ),)
                            ]),
                      )
                  )
                ],
              );
            }
            return Container();
          },
        ),
      ),
    ));
  }

}