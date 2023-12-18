import '../db/entity/tix.dart';
import '../db/entity/tix_backup.dart';
import '../helpers/dummy.dart';

class BackupUtils {
  static TixBackup getTixBackup(Tix tix){
    TixBackup tixBackup = Dummy.getDummyTixBackup();
    tixBackup = tixBackup.copyWith(
      id: tix.id,
        partyId:tix.partyId,
        userId: tix.userId,
        userName: tix.userName,
        userPhone: tix.userPhone,
        userEmail: tix.userEmail,
        igst: tix.igst,
        subTotal: tix.subTotal,
        bookingFee: tix.bookingFee,
        total: tix.total,
        merchantTransactionId: tix.merchantTransactionId,
        transactionId: tix.transactionId,
        transactionResponseCode: tix.transactionResponseCode,
        result: tix.result,
        creationTime: tix.creationTime,
        isSuccess: tix.isSuccess,
        isCompleted: tix.isCompleted,
        isArrived: tix.isArrived,
        tixTierIds: tix.tixTierIds
    );

    return tixBackup;
  }
}