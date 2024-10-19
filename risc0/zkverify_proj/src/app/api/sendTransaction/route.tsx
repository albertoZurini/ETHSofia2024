
import type { NextApiResponse } from 'next'
import { NextResponse } from 'next/server'

type ResponseData = {
  message: string
}

async function sha256(message : string) {
    const encoder = new TextEncoder();
    const data = encoder.encode(message);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashHex = hashArray.map(byte => byte.toString(16).padStart(2, '0')).join('');
    return hashHex;
}
 
async function handler(
  req: Request,
  res: NextApiResponse<ResponseData>
) {
    let body = await req.json()
    console.log(body)

    let reqbody = {
      privateKey: "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
      taxId: 123,
      attestationId: body.attestationId,
      amountTaxDue: 10
    }

    let response = await fetch('http://localhost:3000/accept-tax-application', {
        method: 'POST',
        headers: {
            'Content-type': 'application/json'
        },
        body: JSON.stringify(reqbody)
    })

    response = await response.json()


    return NextResponse.json({ response }, { status: 200 })
}

export { handler as GET, handler as POST };