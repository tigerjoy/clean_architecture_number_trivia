import 'package:clean_architecture_number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({super.key});

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String inputStr = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) {
            inputStr = value;
          },
          onSubmitted: (_) {
            dispatchConcrete();
          },
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
                onPressed: dispatchConcrete,
                child: Text('Search'),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: dispatchRandom,
                child: Text('Get random trivia'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void dispatchConcrete() {
    // Clearing the TextField to prepare it for the next inputted number
    controller.clear();

    BlocProvider.of<NumberTriviaBloc>(
      context,
    ).add(GetTriviaForConcreteNumber(inputStr));
  }

  void dispatchRandom() {
    BlocProvider.of<NumberTriviaBloc>(
      context,
    ).add(GetTriviaForRandomNumber());
  }
}
