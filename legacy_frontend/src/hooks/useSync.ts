import { useState } from 'react';
import { DataService } from '../services/DataService';

export function useSync() {
  const [connected, setConnected] = useState(false);

  async function connect(baseUrl: string) {
    await DataService.syncWithApi(baseUrl);
    setConnected(true);
  }

  return { connected, connect };
}
