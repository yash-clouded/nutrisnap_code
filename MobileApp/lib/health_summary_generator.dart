import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HealthSummaryScreen(),
    );
  }
}

class HealthSummaryScreen extends StatefulWidget {
  @override
  _HealthSummaryScreenState createState() => _HealthSummaryScreenState();
}

class _HealthSummaryScreenState extends State<HealthSummaryScreen> {
  bool _isFullScreen = true;

  @override
  void initState() {
    super.initState();
    // Trigger the animation shortly after the screen loads.
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isFullScreen = false;
        });
      }
    });
  }

  void _toggleLayout() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Calculate the available height of the body, excluding the AppBar.
    final bodyHeight = screenSize.height - kToolbarHeight - MediaQuery.of(context).padding.top;
    // Calculate the initial top position to perfectly center the pie chart in the body.
    final pieChartInitialTop = (bodyHeight / 2) - (screenSize.width / 2);
    // Calculate the initial top position for the summary text, placed below the pie chart.
    final summaryTextInitialTop = (bodyHeight / 2) + (screenSize.width / 2);

    return Scaffold(
      appBar: AppBar(
        title: Text("Macronutrient Summary"),
        actions: [
          IconButton(
            icon: Icon(Icons.replay),
            onPressed: _toggleLayout,
          )
        ],
      ),
      body: Stack(
        children: [
          // Animated Pie Chart
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
            top: _isFullScreen ? pieChartInitialTop : 20,
            left: _isFullScreen ? 0 : 20,
            width: _isFullScreen ? screenSize.width : screenSize.width * 0.4,
            height: _isFullScreen ? screenSize.width : screenSize.width * 0.4,
            child: GestureDetector(
              onTap: _toggleLayout,
              child: MacronutrientPieChart(),
            ),
          ),

          // Detailed Nutrient Breakdown (fades in)
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
            top: 20,
            // Position it to the right of the smaller pie chart
            left: _isFullScreen ? screenSize.width : (screenSize.width * 0.4) + 40,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _isFullScreen ? 0.0 : 1.0,
              child: NutrientBreakdown(),
            ),
          ),

          // Summary Text (moves to bottom)
          AnimatedPositioned(
            duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
            top: _isFullScreen ? summaryTextInitialTop : bodyHeight / 2,
            left: 20,
            right: 20,
            height: _isFullScreen ? 100 : bodyHeight / 2 - 40,
            child: SummaryText(),
          ),
        ],
      ),
    );
  }
}

class MacronutrientPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withOpacity(0.3),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: const Center(
        child: Text(
          "Pie Chart",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}

class NutrientBreakdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nutrient Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 10),
          Text("Carbs: 150g"),
          Text("Calories: 2000 kcal"),
          Text("Protein: 100g"),
          Text("Vitamins: A, C, D"),
          Text("Minerals: Iron, Calcium"),
        ],
      ),
    );
  }
}

class SummaryText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const SingleChildScrollView(
        child: Text(
          "This is a summary of your daily nutritional intake. Based on the analysis, you are meeting your protein goals. However, your carbohydrate intake is slightly higher than recommended. Consider incorporating more fibrous vegetables into your diet. Your vitamin and mineral levels are adequate. Keep up the great work!",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
