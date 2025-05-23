import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_delivery/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart_delivery/features/disbursement/controllers/disbursement_controller.dart';
import 'package:sixam_mart_delivery/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart_delivery/features/disbursement/domain/models/disbursement_report_model.dart';
import 'package:sixam_mart_delivery/helper/date_converter_helper.dart';
import 'package:sixam_mart_delivery/helper/price_converter_helper.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/util/styles.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_app_bar_widget.dart';
import 'package:sixam_mart_delivery/common/widgets/custom_image_widget.dart';
import 'package:sixam_mart_delivery/features/disbursement/widgets/disbursement_status_card_widget.dart';
import 'package:sixam_mart_delivery/features/disbursement/widgets/payment_information_dialog_widget.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class DisbursementScreen extends StatefulWidget {
  const DisbursementScreen({super.key});

  @override
  State<DisbursementScreen> createState() => _DisbursementScreenState();
}

class _DisbursementScreenState extends State<DisbursementScreen> {

  final JustTheController pendingToolTip = JustTheController();
  final JustTheController completedToolTip = JustTheController();
  final JustTheController cancelToolTip = JustTheController();

  @override
  void initState() {
    super.initState();
    Get.find<DisbursementController>().getDisbursementReport(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'disbursement'.tr,
        isBackButtonExist: true,
        actionWidget: GetBuilder<ProfileController>(builder: (profileController) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(200), border: Border.all(width: 1.5, color: Theme.of(context).primaryColor)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(200),
              child: CustomImageWidget(
                image: (profileController.profileModel != null && Get.find<AuthController>().isLoggedIn()) ? profileController.profileModel!.imageFullUrl ?? '' : '',
                width: 35, height: 35, fit: BoxFit.cover,
              ),
            ),
          );
        }),
      ),

      body: GetBuilder<DisbursementController>(builder: (disbursementController) {
        return disbursementController.disbursementReportModel != null ? SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            SizedBox(
              height: 160,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(children: [

                  DisbursementStatusCardWidget(
                    amount: disbursementController.disbursementReportModel!.pending!,
                    text: 'pending_disbursements'.tr,
                    isPending: true,
                    pendingToolTip: pendingToolTip,
                  ),

                  DisbursementStatusCardWidget(
                    amount: disbursementController.disbursementReportModel!.completed!,
                    text: 'completed_disbursements'.tr,
                    isCompleted: true,
                    completeToolTip: completedToolTip,
                  ),

                  DisbursementStatusCardWidget(
                    amount: disbursementController.disbursementReportModel!.canceled!,
                    text: 'canceled_transactions'.tr,
                    isCanceled: true,
                    canceledToolTip: cancelToolTip,
                  ),

                ]),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Text(
                "disbursement_history".tr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),

            (disbursementController.disbursementReportModel!.disbursements != null  && disbursementController.disbursementReportModel!.disbursements!.isNotEmpty)? ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: disbursementController.disbursementReportModel!.disbursements!.length,
              itemBuilder: (context, index) {
                Disbursements disbursement = disbursementController.disbursementReportModel!.disbursements![index];
                return Column(children: [

                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            insetPadding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)), //this right here
                            child: PaymentInformationDialogWidget(disbursement: disbursement),
                          );
                        }
                      );
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(PriceConverterHelper.convertPrice(disbursement.disbursementAmount), style: robotoMedium),
                      subtitle: Text(disbursement.withdrawMethod != null ? '${"payment_method".tr} : ${disbursement.withdrawMethod!.methodName}' : 'payment_method_deleted'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                      trailing: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [

                        Text(
                          DateConverterHelper.dateTimeStringForDisbursement(disbursement.createdAt!),
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            color: disbursement.status == 'pending' ? Colors.blue.withValues(alpha: 0.1) : disbursement.status == 'completed' ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          ),
                          child: Text(disbursement.status!.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: disbursement.status == 'pending' ? Colors.blue : disbursement.status == 'completed' ? Colors.green : Colors.red)),
                        ),

                      ]),
                    ),
                  ),

                  Divider(height: 2, thickness: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.5)),
                ]);
              },
            ) : Padding(padding: const EdgeInsets.only(top: 200), child: Center(child: Text('no_history_available'.tr, style: robotoMedium))),

          ]),

        ) : const Center(child: CircularProgressIndicator());
      }),
    );
  }
}
