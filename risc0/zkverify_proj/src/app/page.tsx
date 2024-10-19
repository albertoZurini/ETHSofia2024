'use client';
import { useState, useRef, useEffect } from 'react';
import { useAccount } from '@/context/AccountContext';
import ConnectWalletButton, { ConnectWalletButtonHandle } from '../components/ConnectWalletButton';
import { useZkVerify } from '@/hooks/useZkVerify';
import styles from './page.module.css';
import proofData from '../proofs/risc0.json';
import Image from 'next/image';

export default function Home() {
  const [loading, setLoading] = useState(false);
  const [verificationResult, setVerificationResult] = useState<string | null>(null);
  const [blockHash, setBlockHash] = useState<string | null>(null);
  const walletButtonRef = useRef<ConnectWalletButtonHandle | null>(null);
  const { selectedAccount } = useAccount();
  const { onVerifyProof, status, eventData, transactionResult, error } = useZkVerify();

  const handleSubmit = async () => {
    if (!selectedAccount) {
      setVerificationResult('Please connect a wallet.');
      return;
    }

    setLoading(true);
    setVerificationResult(null);
    setBlockHash(null);

    const { vk, publicSignals, proof } = proofData;

    try {
      await onVerifyProof(proof, publicSignals, vk);
    } catch (error) {
      setVerificationResult(`Error: ${(error as Error).message}`);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (error) {
      setVerificationResult(error);
    } else if (status === 'verified') {
      setVerificationResult('Proof verified successfully!');
      if (eventData?.blockHash) {
        setBlockHash(eventData.blockHash);
      }
    } else if (status === 'includedInBlock' && eventData) {
      setVerificationResult('Transaction Included In Block');
    } else if (status === 'cancelled') {
      setVerificationResult('Transaction Rejected By User.');
    }
  }, [error, status, eventData]);

  const blockExplorerUrl = blockHash
      ? `https://testnet-explorer.zkverify.io/v0/block/${blockHash}`
      : null;

  useEffect(() => {
    fetch("/api/sendTransaction", {
      method: "POST",
      body: JSON.stringify({a: 1}) // TODO: put the transactionResult.attestationId
    }).then(res => res.json())
    .then(data =>{
      console.log(data)
    })
  })

  return (
      <div className={styles.page}>
        <div className={styles.main}>
          <Image
              src="/zk_Verify_logo_full_black.png"
              alt="zkVerify Logo"
              width={450}
              height={150}
          />

          <ConnectWalletButton ref={walletButtonRef} onWalletConnected={() => {}} />

          <button
              onClick={handleSubmit}
              className={`button ${styles.verifyButton}`}
              disabled={!selectedAccount || loading}
          >
            {loading ? (
                <>
                  Submitting...
                  <div className="spinner"></div>
                </>
            ) : (
                'Submit Proof'
            )}
          </button>

          <div className={styles.resultContainer}>
            {verificationResult && (
                <p
                    className={
                      verificationResult.includes('failed') ||
                      verificationResult.includes('Error') ||
                      verificationResult.includes('Rejected')
                          ? styles.resultError
                          : styles.resultSuccess
                    }
                >
                  {verificationResult}
                </p>
            )}

            {eventData && status === 'includedInBlock' && (
                <div className={styles.resultSection}>
                  <p>Block Hash: {eventData.blockHash || 'N/A'}</p>
                </div>
            )}

            {blockExplorerUrl && (
                <div className={styles.resultLink}>
                  <a href={blockExplorerUrl} target="_blank" rel="noopener noreferrer">
                    View Transaction on Explorer
                  </a>
                </div>
            )}

            {transactionResult && (
                <div className={styles.transactionDetails}>
                  <p>Transaction Hash: {transactionResult.txHash || 'N/A'}</p>
                  <p>Proof Type: {transactionResult.proofType || 'N/A'}</p>
                  <p>Attestation ID: {transactionResult.attestationId || 'N/A'}</p>
                </div>
            )}
          </div>
        </div>
      </div>
  );
}
