import 'package:brainbee/core/constants/bb_colors.dart';
import 'package:brainbee/core/utils/bb_screen_extension.dart';
import 'package:brainbee/core/utils/bb_text.dart';
import 'package:brainbee/core/utils/bb_textTheme_extention.dart';
import 'package:brainbee/core/utils/helper/bb_getinitials.dart';
import 'package:brainbee/presentation/views/home/bloc/student_bloc.dart';
import 'package:brainbee/presentation/views/settings/UI/bb_app_settings.dart';
import 'package:brainbee/presentation/views/settings/UI/bb_change_password.dart';
import 'package:brainbee/presentation/views/settings/UI/bb_learn_and_earn.dart';
import 'package:brainbee/presentation/views/settings/UI/bb_manage_profile.dart';
import 'package:brainbee/presentation/views/settings/UI/bb_select_grade.dart';
import 'package:brainbee/presentation/views/settings/UI/bb_select_subject.dart';
import 'package:brainbee/presentation/views/settings/bloc/setting_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BBSettings extends StatefulWidget {
  const BBSettings({super.key});

  @override
  State<BBSettings> createState() => _BBSettingsState();
}

class _BBSettingsState extends State<BBSettings> {
  int? localGrade;
  // UserModel authenticatedUser = UserModel(
  //   id: '',
  //   email: '',

  //   token: '',
  //   status: '',
  //   firstName: '',
  //   lastName: '',
  // );

  @override
  void initState() {
    super.initState();

    context.read<SettingsBloc>().add(SettingsLoadGradeFromLocal());

    if (context.read<SettingsBloc>().state is SettingsGradeLoadedLocally) {
      localGrade =
          (context.read<SettingsBloc>().state as SettingsGradeLoadedLocally)
              .grade;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: context.screenHeight * 0.05,
        title: BBText(
          data: 'Menu',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: BBColors.white),
        ),
        backgroundColor: BBColors.secondaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: BBColors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: BBColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is StudentDataLoaded) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.only(
                          left: 13,
                          top: 10,
                        ),

                        leading: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.green[700],
                          child: BBText(
                            data: getIntials((state).student.firstName),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: BBColors.white),
                          ),
                        ),
                        title: BBText(
                          data:
                              (state).student.firstName != ''
                                  ? "${(state).student.firstName} ${(state).student.lastName}"
                                  : 'UserName',
                          style: context.textStyle.bodyMedium,
                        ),
                        horizontalTitleGap: 13,
                      ),
                      const Divider(),
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BbManageProfile(),
                            ),
                          );
                        },
                        leading: const Icon(
                          Icons.people,
                          color: BBColors.secondaryColor,
                        ),
                        title: BBText(
                          data: 'Manage Account',
                          style: context.textStyle.bodyMedium,
                        ),
                        visualDensity: const VisualDensity(vertical: -4),
                      ),

                      const Divider(),

                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SelectYearGradeScreen(
                                    student: state.student,
                                  ),
                            ),
                          );
                        },
                        leading: const Icon(
                          Icons.calendar_today,
                          color: BBColors.secondaryColor,
                        ),
                        title: BBText(
                          data: 'Select Year Grade',
                          style: context.textStyle.bodyMedium,
                        ),
                        visualDensity: const VisualDensity(vertical: -4),
                      ),
                      const Divider(),
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SelectSubjectsScreen(
                                    student: state.student,
                                    selectedGrade:
                                        state.student.grade == 0
                                            ? localGrade!
                                            : state.student.grade,
                                  ),
                            ),
                          );
                        },
                        leading: const Icon(
                          Icons.book,
                          color: BBColors.secondaryColor,
                        ),
                        title: BBText(
                          data: 'Select Subjects',
                          style: context.textStyle.bodyMedium,
                        ),
                        visualDensity: const VisualDensity(vertical: -4),
                      ),
                      const Divider(),
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const ChangePasswordScreen(),
                            ),
                          );
                        },
                        leading: const Icon(
                          Icons.lock,
                          color: BBColors.secondaryColor,
                        ),
                        title: BBText(
                          data: 'Change Password',
                          style: context.textStyle.bodyMedium,
                        ),
                        visualDensity: const VisualDensity(vertical: -4),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.share,
                          color: BBColors.secondaryColor,
                        ),
                        title: BBText(
                          data: 'Share My Progress',
                          style: context.textStyle.bodyMedium,
                        ),
                        visualDensity: const VisualDensity(vertical: -4),
                      ),
                      const Divider(),
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AppSettingsScreen(),
                            ),
                          );
                        },
                        leading: const Icon(
                          Icons.settings,
                          color: BBColors.secondaryColor,
                        ),
                        title: BBText(
                          data: 'App Settings',
                          style: context.textStyle.bodyMedium,
                        ),
                        visualDensity: const VisualDensity(vertical: -4),
                      ),
                      const Divider(),
                      ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LearnAndEarnScreen(),
                            ),
                          );
                        },
                        leading: const Icon(
                          Icons.card_giftcard,
                          color: BBColors.secondaryColor,
                        ),
                        title: BBText(
                          data: 'Learn and Earn',
                          style: context.textStyle.bodyMedium,
                        ),
                        visualDensity: const VisualDensity(vertical: -4),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.help,
                          color: BBColors.secondaryColor,
                        ),
                        title: BBText(
                          data: 'Help and Feedback',
                          style: context.textStyle.bodyMedium,
                        ),
                        visualDensity: const VisualDensity(vertical: -4),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: BBColors.secondaryColor,
                        ),
                        title: BBText(
                          data: 'Logout',
                          style: context.textStyle.bodyMedium,
                        ),
                        visualDensity: const VisualDensity(vertical: -4),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: BBText(
                            data: 'See Terms of Services and Privacy Policy',
                            style: Theme.of(context).textTheme.labelMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: BBText(
                            data: 'Version 1.59.2 (1)',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
