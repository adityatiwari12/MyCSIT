import { useState, useEffect } from 'react';
import { subscribeToPendingCount } from '../lib/firestore';

export function usePendingCount(): number {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const unsubscribe = subscribeToPendingCount(setCount);
    return unsubscribe;
  }, []);

  return count;
}
