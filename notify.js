// Vercel Serverless Function: kirim email notifikasi via Resend
// Env: RESEND_API_KEY, MAIL_FROM (opsional, mis. "Vox Angelica <info@domainanda.id>")
module.exports = async (req, res) => {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });
  const { subject, html, to } = req.body || {};
  if (!subject || !html || !Array.isArray(to) || !to.length) return res.status(400).json({ error: 'Data tidak lengkap' });
  const from = process.env.MAIL_FROM || 'Vox Angelica <onboarding@resend.dev>';
  const r = await fetch('https://api.resend.com/emails/batch', {
    method: 'POST',
    headers: { Authorization: `Bearer ${process.env.RESEND_API_KEY}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(to.slice(0, 100).map(t => ({ from, to: [t], subject, html })))
  });
  res.status(r.ok ? 200 : 502).json(await r.json());
};
