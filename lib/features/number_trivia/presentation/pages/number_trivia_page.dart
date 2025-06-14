import 'package:clean_architecture_number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:clean_architecture_number_trivia/features/number_trivia/presentation/widgets/trivia_controls.dart';
import '../widgets/widgets.dart';
import 'package:clean_architecture_number_trivia/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 10,
      ),
      body: SingleChildScrollView(
        child: buildBody(context),
      ),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              // Top Half
              BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) {
                  if (state is Empty) {
                    return MessageDisplay(
                      message: 'Start searching!',
                    );
                  } else if (state is Loading) {
                    return LoadingWidget();
                  } else if (state is Loaded) {
                    return TriviaDisplay(numberTrivia: state.trivia);
                  } else if (state is Error) {
                    return MessageDisplay(message: state.message);
                  }

                  return MessageDisplay(
                    message: "An unexpected error occurred. Please try again.",
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),
              // Bottom half
              TriviaControls(),
            ],
          ),
        ),
      ),
    );
  }
}
