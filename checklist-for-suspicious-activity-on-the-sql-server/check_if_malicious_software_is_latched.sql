SELECT NAME
FROM master..sysobjects
WHERE objectproperty(id, 'ExesIcStartup') = 1