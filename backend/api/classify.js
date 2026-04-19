import { generateText } from "ai";
import { openai } from "@ai-sdk/openai";

export default async function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    let body = req.body;

    if (!body) {
      return res.status(400).json({ error: "Missing body" });
    }

    if (typeof body === "string") {
      body = JSON.parse(body);
    }

    const { image } = body;

    if (!image) {
      return res.status(400).json({ error: "Missing image" });
    }

    const apiKey = process.env.AI_GATEWAY_API_KEY;

    const response = await fetch("https://ai-gateway.vercel.sh/v1/responses", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: "alibaba/qwen3-vl-instruct",
        input: [
          {
            // type: "message",
            role: "user",
            content: [
              {
                type: "input_text",
                text: `
        คุณคือผู้เชี่ยวชาญด้านการแยกขยะตามมาตรฐานถังขยะ 4 ประเภทของประเทศไทย

        ประเภทขยะมีดังนี้:
        1. อินทรีย์ เช่น เศษอาหาร, ใบไม้, เปลือกผลไม้, เศษพืช
        ถึงแม้วัตถุจะอยู่ในถุงพลาสติก ให้ดูที่วัตถุหลักเป็นสำคัญ

        2. รีไซเคิล เช่น ขวดพลาสติก PET, ขวดแก้ว, กระป๋องโลหะ, กระดาษ, กล่องกระดาษ
        ต้องสะอาดและไม่เปื้อนอาหาร จึงจะรีไซเคิลได้

        3. ทั่วไป เช่น ซองขนม, โฟม, ถุงพลาสติก, พลาสติกเปื้อนอาหาร, ของที่รีไซเคิลไม่ได้
        ซองขนม, ถุงพลาสติกทั่วไป แม้ทำจากพลาสติก ก็จัดเป็น "ทั่วไป" ไม่ใช่รีไซเคิล

        4. อันตราย เช่น แบตเตอรี่, ถ่านไฟฉาย, หลอดไฟ, สารเคมี, ขวดยา, วิตามิน, กระป๋องสเปรย์
        ต้องเห็นสัญลักษณ์อันตรายหรือเป็นอุปกรณ์ไฟฟ้าชัดเจน ไม่ใช่แค่ขวดทั่วไป

        กติกา:
        - วิเคราะห์วัตถุหลักในภาพ
        - เลือกได้เพียง 1 ประเภท
        - ตอบ JSON เท่านั้น ห้ามมีข้อความอื่น ห้ามเว้นว่าง

        รูปแบบ:

        {
        "type":"รีไซเคิล",
        "reason":"เป็นขวดพลาสติกสามารถนำไปรีไซเคิลได้"
        }

        ถ้ามองไม่ชัด:

        {
        "type":"ไม่ทราบประเภท",
        "reason":"ไม่สามารถระบุวัตถุในภาพได้"
        }
              `,
              },
              {
                type: "input_image",
                image_url: image,
              },
            ],
          },
        ],
      }),
    });

    const data = await response.json();

    console.log("RAW:", JSON.stringify(data, null, 2));

    let text = null;

    if (data.output) {
      for (const item of data.output) {
        for (const c of item.content || []) {
          if (c.type === "output_text") {
            text = c.text;
            break;
          }
        }
      }
    }

    if (!text) {
      return res.status(500).json({
        error: "AI ไม่ส่งข้อความกลับ",
        raw: data,
      });
    }

    return res.status(200).json({ text });
  } catch (e) {
    return res.status(500).json({
      error: e.toString(),
    });
  }
}
