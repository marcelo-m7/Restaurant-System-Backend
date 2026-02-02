import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSync } from '../hooks/useSync';

export default function ConnectPage() {
  const [url, setUrl] = useState<string>(import.meta.env.VITE_API_BASE_URL || '');
  const { connect } = useSync();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await connect(url);
    navigate('/mesas');
  };

  return (
    <div>
      <h1>Conectar ao Backend</h1>
      <form onSubmit={handleSubmit}>
        <label>URL da API:</label>
        <input
          type="text"
          value={url}
          onChange={e => setUrl(e.target.value)}
          placeholder="https://minha-api.com"
        />
        <button type="submit">Conectar</button>
      </form>
    </div>
  );
}
