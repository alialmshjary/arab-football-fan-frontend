import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 1. استيراد المكتبة

void main() {
  runApp(const MatchesApp());
}

class MatchesApp extends StatelessWidget {
  const MatchesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 2. تطبيق خط Cairo على كامل نصوص التطبيق
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const MatchesScreen(),
    );
  }
}

// ---------------------------------------------------------
// 1. نموذج البيانات (Model) - جاهز للربط مع الباك اند
// ---------------------------------------------------------
class MatchModel {
  final String leagueName;
  final String leagueLogoUrl;
  final String date;
  final String team1Name;
  final String team1LogoUrl;
  final String team2Name;
  final String team2LogoUrl;
  final String time;
  final String round;
  final String stadium;

  MatchModel({
    required this.leagueName,
    required this.leagueLogoUrl,
    required this.date,
    required this.team1Name,
    required this.team1LogoUrl,
    required this.team2Name,
    required this.team2LogoUrl,
    required this.time,
    required this.round,
    required this.stadium,
  });
}

// ---------------------------------------------------------
// 2. واجهة المباريات الرئيسية (Main Screen)
// ---------------------------------------------------------
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({Key? key}) : super(key: key);

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  // بيانات تجريبية تحاكي البيانات القادمة من الباك اند (API)
  final List<MatchModel> matches = [
    MatchModel(
      leagueName: 'دوري روشن السعودي',
      leagueLogoUrl:
          'https://via.placeholder.com/50', // استبدل برابط الشعار الحقيقي
      date: 'الجمعة 24 مايو 2024',
      team1Name: 'الهلال',
      team1LogoUrl: 'https://via.placeholder.com/50',
      team2Name: 'النصر',
      team2LogoUrl: 'https://via.placeholder.com/50',
      time: '9:00 م',
      round: 'الجولة 33',
      stadium: 'ملعب الأول بارك',
    ),
    MatchModel(
      leagueName: 'كأس خادم الحرمين الشريفين',
      leagueLogoUrl: 'https://via.placeholder.com/50',
      date: 'الثلاثاء 28 مايو 2024',
      team1Name: 'الاتحاد',
      team1LogoUrl: 'https://via.placeholder.com/50',
      team2Name: 'الأهلي',
      team2LogoUrl: 'https://via.placeholder.com/50',
      time: '8:45 م',
      round: 'دور الـ 16',
      stadium: 'مدينة الملك عبدالله الرياضية',
    ),
    MatchModel(
      leagueName: 'دوري أبطال آسيا',
      leagueLogoUrl: 'https://via.placeholder.com/50',
      date: 'الأربعاء 5 يونيو 2024',
      team1Name: 'الهلال',
      team1LogoUrl: 'https://via.placeholder.com/50',
      team2Name: 'العين',
      team2LogoUrl: 'https://via.placeholder.com/50',
      time: '7:00 م',
      round: 'نصف النهائي',
      stadium: 'استاد هزاع بن زايد',
    ),
  ];

  int selectedTabIndex = 0; // 0: القادمة, 1: اليوم, 2: انتهت

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'المباريات',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.filter_alt_outlined, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط السدو العربي (تم تكبير المساحة لتظهر الصورة كاملة)
          Container(
            height: 40, // تم التعديل من 15 إلى 40
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/sadu_pattern.jpeg'),
                fit: BoxFit.cover, // يضمن تغطية الصورة للمساحة بشكل مناسب
              ),
              color: Colors.redAccent,
            ),
          ),

          const SizedBox(height: 16),

          // خيارات التصفية (Tabs)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabButton('المباريات القادمة', 0),
                const SizedBox(width: 8),
                _buildTabButton('اليوم', 1),
                const SizedBox(width: 8),
                _buildTabButton('انتهت', 2),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // قائمة المباريات (ListView مهيئة للبيانات الديناميكية)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return MatchCardWidget(match: matches[index]);
              },
            ),
          ),
        ],
      ),

      // شريط التنقل السفلي المخصص
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  // دالة بناء أزرار التبويبات (القادمة، اليوم، انتهت)
  Widget _buildTabButton(String title, int index) {
    bool isActive = selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? Colors.black : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. بطاقة المباراة (Match Card Widget)
// ---------------------------------------------------------
class MatchCardWidget extends StatelessWidget {
  final MatchModel match;

  const MatchCardWidget({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // البطولة والتاريخ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                match.leagueName,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 54, 54, 54),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(match.leagueLogoUrl),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            match.date,
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromARGB(255, 92, 92, 92),
            ),
          ),

          const SizedBox(height: 16),

          // تفاصيل الفريقين والنتيجة/الوقت
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // الفريق الأول
              Column(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(match.team1LogoUrl),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    match.team1Name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              // الوقت والتحدي (VS)
              Column(
                children: [
                  const Text(
                    'VS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromARGB(136, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    match.time,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              // الفريق الثاني
              Column(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(match.team2LogoUrl),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    match.team2Name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEEEEEE), thickness: 1),
          const SizedBox(height: 8),

          // تذييل البطاقة (الجولة والملعب)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                match.round,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 92, 92, 92),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.stadium_outlined,
                    size: 16,
                    color: Color.fromARGB(255, 92, 92, 92),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    match.stadium,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 92, 92, 92),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. شريط التنقل السفلي المخصص (Custom Bottom Nav Bar)
// ---------------------------------------------------------
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),

      child: Row(
        children: [

          Expanded(
            child: _buildNavItem(
              Icons.home_outlined,
              'الرئيسية',
              false,
            ),
          ),

          Expanded(
            child: _buildNavItem(
              Icons.calendar_month,
              'المباريات',
              true,
            ),
          ),

          // 🌟 الزر الأوسط (باستخدام الصورة المخصصة) 🌟
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // أضف الأكشن هنا عند الضغط على الزر
                  print("تم الضغط على زر الإضافة");
                },
                child: Container(
                  height: 55, // يمكنك تكبير أو تصغير الزر من هنا
                  width: 55,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle, // للحفاظ على الإطار الدائري للزر
                    image: DecorationImage(
                      // ⚠️ ضع هنا مسار صورتك التي صممتها للزر
                      image: AssetImage(
                        'assets/add_button_image.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: _buildNavItem(
              Icons.explore_outlined,
              'المنشورات',
              false,
            ),
          ),

          Expanded(
            child: _buildNavItem(
              Icons.person_outline,
              'الملف الشخصي',
              false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.red : Colors.grey,
          size: 26,
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.red : Colors.grey,
            fontSize: 10,
            fontWeight:
                isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}