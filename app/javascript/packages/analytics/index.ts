import { getConfigValue } from '@18f/identity-config';

/**
 * Logs an event.
 *
 * @param event Event name.
 * @param payload Payload object.
 *
 * @return Promise resolving once event has been logged.
 */
export async function trackEvent(event: string, payload: object = {}): Promise<void> {
  const endpoint = getConfigValue('analyticsEndpoint');
  if (endpoint) {
    await window.fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ event, payload }),
    });
  }
}
