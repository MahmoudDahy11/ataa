import { getFirestore, Timestamp } from "firebase-admin/firestore";

import { deleteObject } from "./storj-service";

export async function deleteOrphanSessions(): Promise<void> {
  const now = Timestamp.now();
  const db = getFirestore();
  const snap = await db.collection("upload_sessions")
    .where("used", "==", false)
    .where("expiresAt", "<", now)
    .get();

  const results = await Promise.allSettled(
    snap.docs.map(async (doc) => {
      const { fileKey } = doc.data();
      try {
        await deleteObject(fileKey);
      } catch (err) {
        console.error(`[cleanup] storj delete failed for ${fileKey}:`, err);
      }
      await doc.ref.delete();
    })
  );

  const failed = results.filter(r => r.status === "rejected").length;
  if (failed > 0) {
    console.error(`[cleanup] ${failed} session(s) failed to clean up`);
  }
}
