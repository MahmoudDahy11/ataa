import { getFirestore, FieldValue } from "firebase-admin/firestore";

const labels: Record<string, string> = {
  id_card: "بطاقة الرقم القومي",
  medical_report: "تقرير طبي",
  debt_proof: "إثبات مديونية",
};

type DocumentInput = {
  fileKey: string;
  fileName: string;
  mimeType: string;
  ownerId: string;
  sizeBytes: number;
  type: string;
};

export async function createDocument(input: DocumentInput): Promise<Record<string, unknown>> {
  const docRef = getFirestore().collection("documents").doc();
  const timestamp = new Date().toISOString();
  const payload = {
    id: docRef.id,
    ownerId: input.ownerId,
    type: input.type,
    displayName: labels[input.type] ?? input.type,
    fileName: input.fileName,
    mimeType: input.mimeType,
    sizeBytes: input.sizeBytes,
    storageKey: input.fileKey,
    status: "stored",
    uploadId: null,
    isDeleted: false,
    schemaVersion: 1,
    createdAt: timestamp,
    updatedAt: timestamp,
  };
  await docRef.set({
    ...payload,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });
  return payload;
}
